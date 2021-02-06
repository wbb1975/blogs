# 访问 API
关于 Kubernetes 如何实现和控制 API 访问的介绍性材料，可阅读 [控制 Kubernetes API 的访问](https://kubernetes.io/zh/docs/concepts/security/controlling-access/)。

参考文档：
- [身份认证](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/)
  + [使用启动引导令牌来执行身份认证](https://kubernetes.io/zh/docs/reference/access-authn-authz/bootstrap-tokens/)
- [准入控制器](https://kubernetes.io/zh/docs/reference/access-authn-authz/admission-controllers/)
  + [动态准入控制](https://kubernetes.io/zh/docs/reference/access-authn-authz/extensible-admission-controllers/)
- [鉴权与授权](https://kubernetes.io/zh/docs/reference/access-authn-authz/authorization/)
  + [基于角色的访问控制](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/)
  + [基于属性的访问控制](https://kubernetes.io/zh/docs/reference/access-authn-authz/abac/)
  + [节点鉴权](https://kubernetes.io/zh/docs/reference/access-authn-authz/node/)
  + [Webhook 鉴权](https://kubernetes.io/zh/docs/reference/access-authn-authz/webhook/)
- [证书签名请求](https://kubernetes.io/zh/docs/reference/access-authn-authz/certificate-signing-requests/)
  + 包含 [CSR 的批复](https://kubernetes.io/zh/docs/reference/access-authn-authz/certificate-signing-requests/#approval-rejection)和[证书签名](https://kubernetes.io/zh/docs/reference/access-authn-authz/certificate-signing-requests/#signing)
- 服务账号
  + [开发者指南](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-service-account/)
  + [管理文档](https://kubernetes.io/zh/docs/reference/access-authn-authz/service-accounts-admin/)
## 1. 用户认证
本页提供身份认证有关的概述。
### 1.1 Kubernetes 中的用户
所有 Kubernetes 集群都有两类用户：由 Kubernetes 管理的服务账号和普通用户。

Kubernetes 假定普通用户是由一个与集群无关的服务通过以下方式之一进行管理的：
- 负责分发私钥的管理员
- 类似 Keystone 或者 Google Accounts 这类用户数据库
- 包含用户名和密码列表的文件

有鉴于此，Kubernetes 并不包含用来代表普通用户账号的对象。 普通用户的信息无法通过 API 调用添加到集群中。

尽管无法通过 API 调用来添加普通用户，Kubernetes 仍然认为能够提供由集群的证书机构签名的合法证书的用户是通过身份认证的用户。基于这样的配置，Kubernetes 使用证书中的 'subject' 的通用名称（Common Name）字段（例如，"/CN=bob"）来 确定用户名。接下来，基于角色访问控制（RBAC）子系统会确定用户是否有权针对 某资源执行特定的操作。进一步的细节可参阅[证书请求](https://kubernetes.io/zh/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user)下普通用户主题。

与此不同，服务账号是 Kubernetes API 所管理的用户。它们被绑定到特定的名字空间， 或者由 API 服务器自动创建，或者通过 API 调用创建。服务账号与一组以 Secret 保存 的凭据相关，这些凭据会被挂载到 Pod 中，从而允许集群内的进程访问 Kubernetes API。

API 请求则或者与某普通用户相关联，或者与某服务账号相关联，亦或者被视作[匿名请求](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#anonymous-requests)。这意味着集群内外的每个进程在向 API 服务器发起 请求时都必须通过身份认证，否则会被视作匿名用户。这里的进程可以是在某工作站上 输入 kubectl 命令的操作人员，也可以是节点上的 kubelet 组件，还可以是控制面的成员。
### 1.2 身份认证策略
Kubernetes 使用身份认证插件利用客户端证书、持有者令牌（Bearer Token）、身份认证代理（Proxy） 或者 HTTP 基本认证机制来认证 API 请求的身份。HTTP 请求发给 API 服务器时， 插件会将以下属性关联到请求本身：
- 用户名：用来辩识最终用户的字符串。常见的值可以是 kube-admin 或 jane@example.com。
- 用户ID：用来辩识最终用户的字符串，旨在比用户名有更好的一致性和唯一性。
- 用户组：取值为一组字符串，其中各个字符串用来标明用户是某个命名的用户逻辑集合的成员。 常见的值可能是 system:masters 或者 devops-team 等。
- 附加字段：一组额外的键-值映射，键是字符串，值是一组字符串；用来保存一些鉴权组件可能 觉得有用的额外信息。

所有（属性）值对于身份认证系统而言都是不透明的，只有被[鉴权组件](https://kubernetes.io/zh/docs/reference/access-authn-authz/authorization/)解释过之后才有意义。

你可以同时启用多种身份认证方法，并且你通常会至少使用两种方法：
- 针对服务账号使用服务账号令牌
- 至少另外一种方法对用户的身份进行认证

当集群中启用了多个身份认证模块时，第一个成功地对请求完成身份认证的模块会 直接做出评估决定。API 服务器并不保证身份认证模块的运行顺序。

对于所有通过身份认证的用户，`system:authenticated` 组都会被添加到其组列表中。

与其它身份认证协议（LDAP、SAML、Kerberos、X509 的替代模式等等）都可以通过 使用一个[身份认证代理](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#authenticating-proxy)或身份认证 [Webhoook](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#webhook-token-authentication) 来实现。
#### 1.2.1 X509 客户证书
通过给 API 服务器传递 `--client-ca-file=SOMEFILE` 选项，就可以启动客户端证书身份认证。 所引用的文件必须包含一个或者多个证书机构，用来验证向 API 服务器提供的客户端证书。 如果提供了客户端证书并且证书被验证通过，则 `subject` 中的公共名称（Common Name）就被 作为请求的用户名。 自 Kubernetes 1.4 开始，客户端证书还可以通过证书的 `organization` 字段标明用户的组成员信息。 要包含用户的多个组成员信息，可以在证书种包含多个 `organization` 字段。

例如，使用 openssl 命令行工具生成一个证书签名请求：
```
openssl req -new -key jbeda.pem -out jbeda-csr.pem -subj "/CN=jbeda/O=app1/O=app2"
```
此命令将使用用户名 jbeda 生成一个证书签名请求（CSR），且该用户属于 "app" 和 "app2" 两个用户组。

参阅[管理证书](https://kubernetes.io/zh/docs/concepts/cluster-administration/certificates/)了解如何生成客户端证书。
#### 1.2.2 静态令牌文件
当 API 服务器的命令行设置了 --token-auth-file=SOMEFILE 选项时，会从文件中 读取持有者令牌。目前，令牌会长期有效，并且在不重启 API 服务器的情况下 无法更改令牌列表。

令牌文件是一个 CSV 文件，包含至少 3 个列：令牌、用户名和用户的 UID。 其余列被视为可选的组名。
> **说明**：如果要设置的组名不止一个，则对应的列必须用双引号括起来，例如`token,user,uid,"group1,group2,group3"`

**在请求中放入持有者令牌**
当使用持有者令牌来对某 HTTP 客户端执行身份认证时，API 服务器希望看到 一个名为 `Authorization` 的 HTTP 头，其值格式为 `Bearer THETOKEN`。 持有者令牌必须是一个可以放入 HTTP 头部值字段的字符序列，至多可使用 HTTP 的编码和引用机制。 例如：如果持有者令牌为 `31ada4fd-adec-460c-809a-9e56ceb75269`，则其 出现在 HTTP 头部时如下所示：
```
Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269
```
#### 1.2.3 启动引导令牌
**FEATURE STATE: Kubernetes v1.18 [stable]**

为了支持平滑地启动引导新的集群，Kubernetes 包含了一种动态管理的持有者令牌类型， 称作 启动引导令牌（`Bootstrap Token`）。 这些令牌以 `Secret` 的形式保存在 `kube-system` 名字空间中，可以被动态管理和创建。 控制器管理器包含的 `TokenCleaner` 控制器能够在启动引导令牌过期时将其删除。

这些令牌的格式为 `[a-z0-9]{6}.[a-z0-9]{16}`。第一个部分是令牌的 `ID`；第二个部分 是令牌的 `Secret`。你可以用如下所示的方式来在 HTTP 头部设置令牌：
```
Authorization: Bearer 781292.db7bc3a58fc5f07e
```
你必须在 API 服务器上设置 `--enable-bootstrap-token-auth` 标志来启用基于启动 引导令牌的身份认证组件。 你必须通过控制器管理器的 `--controllers` 标志来启用 `TokenCleaner` 控制器； 这可以通过类似 `--controllers=*,tokencleaner` 这种设置来做到。 如果你使用 `kubeadm` 来启动引导新的集群，该工具会帮你完成这些设置。

身份认证组件的认证结果为 `system:bootstrap:<令牌 ID>`，该用户属于 `system:bootstrappers` 用户组。 这里的用户名和组设置都是有意设计成这样，其目的是阻止用户在启动引导集群之后继续使用这些令牌。这里的用户名和组名可以用来（并且已经被 `kubeadm` 用来）构造合适的鉴权策略，以完成启动引导新集群的工作。

请参阅[启动引导令牌](https://kubernetes.io/zh/docs/reference/access-authn-authz/bootstrap-tokens/)以了解关于启动引导令牌身份认证组件与控制器的更深入的信息，以及如何使用 `kubeadm` 来管理这些令牌。
#### 1.2.4 服务账号令牌
服务账号（Service Account）是一种自动被启用的用户认证机制，使用经过签名的持有者令牌来验证请求。该插件可接受两个可选参数：
- `--service-account-key-file` 一个包含用来为持有者令牌签名的 PEM 编码密钥。 若未指定，则使用 API 服务器的 TLS 私钥。
- `-service-account-lookup` 如果启用，则从 API 删除的令牌会被回收。

服务账号通常由 API 服务器自动创建并通过 `ServiceAccount` 准入控制器 关联到集群中运行的 Pod 上。 持有者令牌会挂载到 Pod 中可预知的位置，允许集群内进程与 API 服务器通信。 服务账号也可以使用 Pod 规约的 `serviceAccountName` 字段显式地关联到 Pod 上。

> **说明**： `serviceAccountName` 通常会被忽略，因为关联关系是自动建立的。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 3
  template:
    metadata:
    # ...
    spec:
      serviceAccountName: bob-the-bot
      containers:
      - name: nginx
        image: nginx:1.14.2
```
在集群外部使用服务账号持有者令牌也是完全合法的，且可用来为长时间运行的、需要与 Kubernetes API 服务器通信的任务创建标识。要手动创建服务账号，可以使用 `kubectl create serviceaccount <名称>` 命令。此命令会在当前的名字空间中生成一个 服务账号和一个与之关联的 `Secret`。
```
kubectl create serviceaccount jenkins

serviceaccount/jenkins created
```
查验相关联的 `Secret`：
```
kubectl get serviceaccounts jenkins -o yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  # ...
secrets:
- name: jenkins-token-1yvwg
```
所创建的 Secret 中会保存 API 服务器的公开的 CA 证书和一个已签名的 JSON Web 令牌（JWT）。
```
kubectl get secret jenkins-token-1yvwg -o yaml

apiVersion: v1
data:
  ca.crt: <Base64 编码的 API 服务器 CA>
  namespace: ZGVmYXVsdA==
  token: <Base64 编码的持有者令牌>
kind: Secret
metadata:
  # ...
type: kubernetes.io/service-account-token
```
> **说明**： 字段值是按 Base64 编码的，这是因为 Secret 数据总是采用 Base64 编码来存储。

已签名的 `JWT` 可以用作持有者令牌，并将被认证为所给的服务账号。关于如何在请求中包含令牌，请参阅[前文](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#putting-a-bearer-token-in-a-request)。通常，这些 `Secret` 数据会被挂载到 Pod 中以便集群内访问 API 服务器时使用，不过也可以在集群外部使用。

服务账号被身份认证后，所确定的用户名为 `system:serviceaccount:<名字空间>:<服务账号>`，并被分配到用户组 `system:serviceaccounts` 和 `system:serviceaccounts:<名字空间>`。

> **警告**：由于服务账号令牌保存在 `Secret` 对象中，任何能够读取这些 `Secret` 的用户都可以被认证为对应的服务账号。在为用户授予访问服务账号的权限时，以及对 `Secret` 的读权限时，要格外小心。
#### 1.2.5 OpenID Connect（OIDC）令牌
[OpenID Connect](https://openid.net/connect/) 是一种 OAuth2 认证方式，被某些 OAuth2 提供者支持，例如 Azure 活动目录、Salesforce 和 Google。协议对 OAuth2 的主要扩充体现在有一个附加字段会和访问令牌一起返回，这一字段称作 `[ID Token（ID 令牌）](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)`。`ID 令牌` 是一种由服务器签名的 JSON Web 令牌（JWT），其中包含一些可预知的字段，例如用户的邮箱地址。

要识别用户，身份认证组件使用 OAuth2 [令牌响应](https://openid.net/specs/openid-connect-core-1_0.html#TokenResponse)中的 `id_token`（而非 `access_token`）作为持有者令牌。关于如何在请求中设置令牌，可参见[前文](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#putting-a-bearer-token-in-a-request)。

![OIDC令牌](oidc_kubernets.png)

1. 登录到你的身份服务（Identity Provider）
2. 你的身份服务将为你提供 access_token、id_token 和 refresh_token
3. 在使用 kubectl 时，将 id_token 设置为 --token 标志值，或者将其直接添加到 kubeconfig 中
4. kubectl 将你的 id_token 放到一个称作 Authorization 的头部，发送给 API 服务器
5. API 服务器将负责通过检查配置中引用的证书来确认 JWT 的签名是合法的
6. 检查确认 id_token 尚未过期
7. 确认用户有权限执行操作
8. 鉴权成功之后，API 服务器向 kubectl 返回响应
9. kubectl 向用户提供反馈信息

由于用来验证你是谁的所有数据都在 id_token 中，Kubernetes 不需要再去联系身份服务。在一个所有请求都是无状态请求的模型中，这一工作方式可以使得身份认证的解决方案更容易处理大规模请求。不过，此访问也有一些挑战：
1. Kubernetes 没有提供用来触发身份认证过程的 "Web 界面"。因为不存在用来收集用户凭据的浏览器或用户接口，你必须自己先行完成对身份服务的认证过程。
3. id_token 令牌不可收回。因其属性类似于证书，其生命期一般很短（只有几分钟），所以，每隔几分钟就要获得一个新的令牌这件事可能很让人头疼。
3. 如果不使用 kubectl proxy 命令或者一个能够注入 id_token 的反向代理，向 Kubernetes 控制面板执行身份认证是很困难的。

**配置 API 服务器**
要启用此插件，须在 API 服务器上配置以下标志：
参数|描述|示例|必需？
--------|--------|--------|--------
--oidc-issuer-url|允许 API 服务器发现公开的签名密钥的服务的 URL。只接受模式为 https:// 的 URL。此值通常设置为服务的发现 URL，不含路径。例如："https://accounts.google.com" 或 "https://login.salesforce.com"。此 URL 应指向 .well-known/openid-configuration 下一层的路径。|如果发现 URL 是 https://accounts.google.com/.well-known/openid-configuration，则此值应为 https://accounts.google.com|	是
--oidc-client-id|所有令牌都应发放给此客户 ID|kubernetes|是
--oidc-username-claim|用作用户名的 JWT 申领（JWT Claim）。默认情况下使用 sub 值，即最终用户的一个唯一的标识符。管理员也可以选择其他申领，例如 email 或者 name，取决于所用的身份服务。不过，除了 email 之外的申领都会被添加令牌发放者的 URL 作为前缀，以免与其他插件产生命名冲突。|sub|否
--oidc-username-prefix|要添加到用户名申领之前的前缀，用来避免与现有用户名发生冲突（例如：system: 用户）。例如，此标志值为 oidc: 时将创建形如 oidc:jane.doe 的用户名。如果此标志未设置，且 --oidc-username-claim 标志值不是 email，则默认前缀为 <令牌发放者的 URL>#，其中 <令牌发放者 URL > 的值取自 --oidc-issuer-url 标志的设定。此标志值为 - 时，意味着禁止添加用户名前缀。|oidc:|否
--oidc-groups-claim|用作用户组名的 JWT 申领。如果所指定的申领确实存在，则其值必须是一个字符串数组。|groups|否
--oidc-groups-prefix|添加到组申领的前缀，用来避免与现有用户组名（如：system: 组）发生冲突。例如，此标志值为 oidc: 时，所得到的用户组名形如 oidc:engineering 和 oidc:infra|	oidc:|否
--oidc-required-claim|取值为一个 key=value 偶对，意为 ID 令牌中必须存在的申领。如果设置了此标志，则 ID 令牌会被检查以确定是否包含取值匹配的申领。此标志可多次重复，以指定多个申领。|claim=value|否
--oidc-ca-file|指向一个 CA 证书的路径，该 CA 负责对你的身份服务的 Web 证书提供签名。默认值为宿主系统的根 CA。|/etc/kubernetes/ssl/kc-ca.pem|否

很重要的一点是，API 服务器并非一个 OAuth2 客户端，相反，它只能被配置为 信任某一个令牌发放者。这使得使用公共服务（如 Google）的用户可以不信任发放给第三方的凭据。如果管理员希望使用多个 OAuth 客户端，他们应该研究一下那些支持 `azp`（Authorized Party，被授权方）申领的服务。`azp` 是一种允许某客户端代替另一客户端发放令牌的机制。

Kubernetes 并未提供 OpenID Connect 的身份服务。 你可以使用现有的公共的 OpenID Connect 身份服务（例如 Google 或者[其他服务](https://connect2id.com/products/nimbus-oauth-openid-connect-sdk/openid-connect-providers)）。或者，你也可以选择自己运行一个身份服务，例如 CoreOS [dex](https://github.com/coreos/dex)、[Keycloak}(https://github.com/keycloak/keycloak)、CloudFoundry [UAA](https://github.com/cloudfoundry/uaa) 或者 Tremolo Security 的 [OpenUnison](https://github.com/tremolosecurity/openunison)。

要在 Kubernetes 环境中使用某身份服务，该服务必须：
1. 支持 [OpenID connect}(https://openid.net/specs/openid-connect-discovery-1_0.html) 发现； 但事实上并非所有服务都具备此能力
2. 运行 TLS 协议且所使用的加密组件都未过时
3. 拥有由 CA 签名的证书（即使 CA 不是商业 CA 或者是自签名的 CA 也可以）

关于上述第三条需求，即要求具备 CA 签名的证书，有一些额外的注意事项。如果你部署了自己的身份服务，而不是使用云厂商（如 Google 或 Microsoft）所提供的服务，你必须对身份服务的 Web 服务器证书进行签名，签名所用证书的 CA 标志要设置为 TRUE，即使用的是自签名证书。这是因为 GoLang 的 TLS 客户端实现对证书验证 标准方面有非常严格的要求。如果你手头没有现成的 CA 证书，可以使用 CoreOS 团队所开发的这个[脚本](https://github.com/dexidp/dex/blob/master/examples/k8s/gencert.sh)来创建一个简单的 CA 和被签了名的证书与密钥对。或者你也可以使用[这个类似的脚本](https://raw.githubusercontent.com/TremoloSecurity/openunison-qs-kubernetes/master/src/main/bash/makessl.sh)，生成一个合法期更长、密钥尺寸更大的 SHA256 证书。

特定系统的安装指令：
- [UAA](https://docs.cloudfoundry.org/concepts/architecture/uaa.html)
- [Dex](https://dexidp.io/docs/kubernetes/)
- [OpenUnison](https://www.tremolosecurity.com/orchestra-k8s/)

**使用 kubectl**
- **选项一 OIDC 身份认证组件**
  第一种方案是使用 kubectl 的 `oidc` 身份认证组件，该组件将 `id_token` 设置为所有请求的持有者令牌，并且在令牌过期时自动刷新。在你登录到你的身份服务之后，可以使用 kubectl 来添加你的 `id_token`、`refresh_token`、`client_id` 和 `client_secret`，以配置该插件。

  如果服务在其刷新令牌响应中不包含 `id_token`，则此插件无法支持该服务。 这时你应该考虑下面的选项二。

  ```
  kubectl config set-credentials USER_NAME \
   --auth-provider=oidc \
   --auth-provider-arg=idp-issuer-url=( issuer url ) \
   --auth-provider-arg=client-id=( your client id ) \
   --auth-provider-arg=client-secret=( your client secret ) \
   --auth-provider-arg=refresh-token=( your refresh token ) \
   --auth-provider-arg=idp-certificate-authority=( path to your ca certificate ) \
   --auth-provider-arg=id-token=( your id_token )
  ```
  作为示例，在完成对你的身份服务的身份认证之后，运行下面的命令：
  ```
  kubectl config set-credentials mmosley  \
        --auth-provider=oidc  \
        --auth-provider-arg=idp-issuer-url=https://oidcidp.tremolo.lan:8443/auth/idp/OidcIdP  \
        --auth-provider-arg=client-id=kubernetes  \
        --auth-provider-arg=client-secret=1db158f6-177d-4d9c-8a8b-d36869918ec5  \
        --auth-provider-arg=refresh-token=q1bKLFOyUiosTfawzA93TzZIDzH2TNa2SMm0zEiPKTUwME6BkEo6Sql5yUWVBSWpKUGphaWpxSVAfekBOZbBhaEW+VlFUeVRGcluyVF5JT4+haZmPsluFoFu5XkpXk5BXqHega4GAXlF+ma+vmYpFcHe5eZR+slBFpZKtQA= \
        --auth-provider-arg=idp-certificate-authority=/root/ca.pem \
        --auth-provider-arg=id-token=eyJraWQiOiJDTj1vaWRjaWRwLnRyZW1vbG8ubGFuLCBPVT1EZW1vLCBPPVRybWVvbG8gU2VjdXJpdHksIEw9QXJsaW5ndG9uLCBTVD1WaXJnaW5pYSwgQz1VUy1DTj1rdWJlLWNhLTEyMDIxNDc5MjEwMzYwNzMyMTUyIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL29pZGNpZHAudHJlbW9sby5sYW46ODQ0My9hdXRoL2lkcC9PaWRjSWRQIiwiYXVkIjoia3ViZXJuZXRlcyIsImV4cCI6MTQ4MzU0OTUxMSwianRpIjoiMm96US15TXdFcHV4WDlHZUhQdy1hZyIsImlhdCI6MTQ4MzU0OTQ1MSwibmJmIjoxNDgzNTQ5MzMxLCJzdWIiOiI0YWViMzdiYS1iNjQ1LTQ4ZmQtYWIzMC0xYTAxZWU0MWUyMTgifQ.w6p4J_6qQ1HzTG9nrEOrubxIMb9K5hzcMPxc9IxPx2K4xO9l-oFiUw93daH3m5pluP6K7eOE6txBuRVfEcpJSwlelsOsW8gb8VJcnzMS9EnZpeA0tW_p-mnkFc3VcfyXuhe5R3G7aa5d8uHv70yJ9Y3-UhjiN9EhpMdfPAoEB9fYKKkJRzF7utTTIPGrSaSU6d2pcpfYKaxIwePzEkT4DfcQthoZdy9ucNvvLoi1DIC-UocFD8HLs8LYKEqSxQvOcvnThbObJ9af71EwmuE21fO5KzMW20KtAeget1gnldOosPtz1G5EwvaQ401-RPQzPGMVBld0_zMCAwZttJ4knw
  ```
  此操作会生成以下配置：
  ```
  users:
  - name: mmosley
  user:
    auth-provider:
      config:
        client-id: kubernetes
        client-secret: 1db158f6-177d-4d9c-8a8b-d36869918ec5
        id-token: eyJraWQiOiJDTj1vaWRjaWRwLnRyZW1vbG8ubGFuLCBPVT1EZW1vLCBPPVRybWVvbG8gU2VjdXJpdHksIEw9QXJsaW5ndG9uLCBTVD1WaXJnaW5pYSwgQz1VUy1DTj1rdWJlLWNhLTEyMDIxNDc5MjEwMzYwNzMyMTUyIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL29pZGNpZHAudHJlbW9sby5sYW46ODQ0My9hdXRoL2lkcC9PaWRjSWRQIiwiYXVkIjoia3ViZXJuZXRlcyIsImV4cCI6MTQ4MzU0OTUxMSwianRpIjoiMm96US15TXdFcHV4WDlHZUhQdy1hZyIsImlhdCI6MTQ4MzU0OTQ1MSwibmJmIjoxNDgzNTQ5MzMxLCJzdWIiOiI0YWViMzdiYS1iNjQ1LTQ4ZmQtYWIzMC0xYTAxZWU0MWUyMTgifQ.w6p4J_6qQ1HzTG9nrEOrubxIMb9K5hzcMPxc9IxPx2K4xO9l-oFiUw93daH3m5pluP6K7eOE6txBuRVfEcpJSwlelsOsW8gb8VJcnzMS9EnZpeA0tW_p-mnkFc3VcfyXuhe5R3G7aa5d8uHv70yJ9Y3-UhjiN9EhpMdfPAoEB9fYKKkJRzF7utTTIPGrSaSU6d2pcpfYKaxIwePzEkT4DfcQthoZdy9ucNvvLoi1DIC-UocFD8HLs8LYKEqSxQvOcvnThbObJ9af71EwmuE21fO5KzMW20KtAeget1gnldOosPtz1G5EwvaQ401-RPQzPGMVBld0_zMCAwZttJ4knw
        idp-certificate-authority: /root/ca.pem
        idp-issuer-url: https://oidcidp.tremolo.lan:8443/auth/idp/OidcIdP
        refresh-token: q1bKLFOyUiosTfawzA93TzZIDzH2TNa2SMm0zEiPKTUwME6BkEo6Sql5yUWVBSWpKUGphaWpxSVAfekBOZbBhaEW+VlFUeVRGcluyVF5JT4+haZmPsluFoFu5XkpXk5BXq
      name: oidc
  ```
  当你的 `id_token` 过期时，kubectl 会尝试使用你的 `refresh_token` 来刷新你的 `id_token`，并且在 `client_secret` 中存放 `refresh_token` 的新值，同时把 `id_token` 的新值写入到 `.kube/config` 文件中。
- **选项二 使用 --token 选项**
  kubectl 命令允许你使用 --token 选项传递一个令牌。 你可以将 id_token 的内容复制粘贴过来，作为此标志的取值：
  ```
  kubectl --token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL21sYi50cmVtb2xvLmxhbjo4MDQzL2F1dGgvaWRwL29pZGMiLCJhdWQiOiJrdWJlcm5ldGVzIiwiZXhwIjoxNDc0NTk2NjY5LCJqdGkiOiI2RDUzNXoxUEpFNjJOR3QxaWVyYm9RIiwiaWF0IjoxNDc0NTk2MzY5LCJuYmYiOjE0NzQ1OTYyNDksInN1YiI6Im13aW5kdSIsInVzZXJfcm9sZSI6WyJ1c2VycyIsIm5ldy1uYW1lc3BhY2Utdmlld2VyIl0sImVtYWlsIjoibXdpbmR1QG5vbW9yZWplZGkuY29tIn0.f2As579n9VNoaKzoF-dOQGmXkFKf1FMyNV0-va_B63jn-_n9LGSCca_6IVMP8pO-Zb4KvRqGyTP0r3HkHxYy5c81AnIh8ijarruczl-TK_yF5akjSTHFZD-0gRzlevBDiH8Q79NAr-ky0P4iIXS8lY9Vnjch5MF74Zx0c3alKJHJUnnpjIACByfF2SCaYzbWFMUNat-K1PaUk5-ujMBG7yYnr95xD-63n8CO8teGUAAEMx6zRjzfhnhbzX-ajwZLGwGUBT4WqjMs70-6a7_8gZmLZb2az1cZynkFRj2BaCkVT3A2RrjeEwZEtGXlMqKJ1_I2ulrOVsYx01_yD35-rw get nodes
  ```
#### 1.2.6 Webhook 令牌身份认证
Webhook 身份认证是一种用来验证持有者令牌的回调机制。
- `--authentication-token-webhook-config-file` 指向一个配置文件，其中描述 如何访问远程的 Webhook 服务。
- `--authentication-token-webhook-cache-ttl` 用来设定身份认证决定的缓存时间。 默认时长为 2 分钟。

配置文件使用 [kubeconfig](https://kubernetes.io/zh/docs/concepts/configuration/organize-cluster-access-kubeconfig/) 文件的格式。文件中，`clusters` 指代远程服务，`users`` 指代远程 API 服务 `Webhook`。下面是一个例子：
```
# Kubernetes API 版本
apiVersion: v1
# API 对象类别
kind: Config
# clusters 指代远程服务
clusters:
  - name: name-of-remote-authn-service
    cluster:
      certificate-authority: /path/to/ca.pem         # 用来验证远程服务的 CA
      server: https://authn.example.com/authenticate # 要查询的远程服务 URL。必须使用 'https'。

# users 指代 API 服务的 Webhook 配置
users:
  - name: name-of-api-server
    user:
      client-certificate: /path/to/cert.pem # Webhook 插件要使用的证书
      client-key: /path/to/key.pem          # 与证书匹配的密钥

# kubeconfig 文件需要一个上下文（Context），此上下文用于本 API 服务器
current-context: webhook
contexts:
- context:
    cluster: name-of-remote-authn-service
    user: name-of-api-sever
  name: webhook
```
当客户端尝试在 API 服务器上使用持有者令牌完成身份认证（ [如前](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#putting-a-bearer-token-in-a-request)所述）时，身份认证 `Webhook` 会用 `POST` 请求发送一个 JSON 序列化的对象到远程服务。 该对象是 `authentication.k8s.io/v1beta1` 组的 `TokenReview` 对象，其中包含持有者令牌。`Kubernetes` 不会强制请求提供此 HTTP 头部。

要注意的是，`Webhook API` 对象和其它 Kubernetes API 对象一样，也要受到同一 版本兼容规则约束。实现者要了解对 `Beta` 阶段对象的兼容性承诺，并检查请求的 `apiVersion` 字段， 以确保数据结构能够正常反序列化解析。此外，API 服务器必须启用 `authentication.k8s.io/v1beta1` API 扩展组 （`--runtime-config=authentication.k8s.io/v1beta1=true`）。

POST 请求的 Body 部分将是如下格式：
```
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "spec": {
    "token": "<持有者令牌>"
  }
}
```
远程服务应该会填充请求的 status 字段，以标明登录操作是否成功。 响应的 Body 中的 spec 字段会被忽略，因此可以省略。 如果持有者令牌验证成功，应该返回如下所示的响应：
```
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "status": {
    "authenticated": true,
    "user": {
      "username": "janedoe@example.com",
      "uid": "42",
      "groups": [
        "developers",
        "qa"
      ],
      "extra": {
        "extrafield1": [
          "extravalue1",
          "extravalue2"
        ]
      }
    }
  }
}
```
而不成功的请求会返回：
```
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "status": {
    "authenticated": false
  }
}
```
HTTP 状态码可用来提供进一步的错误语境信息。
#### 1.2.7 身份认证代理
API 服务器可以配置成从请求的头部字段值（如 X-Remote-User）中辩识用户。 这一设计是用来与某身份认证代理一起使用 API 服务器，代理负责设置请求的头部字段值。
- `--requestheader-username-headers` 必需字段，大小写不敏感。用来设置要获得用户身份所要检查的头部字段名称列表（有序）。第一个包含数值的字段会被用来提取用户名。
- `--requestheader-group-headers` 可选字段，在 Kubernetes 1.6 版本以后支持，大小写不敏感。建议设置为 "X-Remote-Group"。用来指定一组头部字段名称列表，以供检查用户所属的组名称。 所找到的全部头部字段的取值都会被用作用户组名。
- `--requestheader-extra-headers-prefix` 可选字段，在 Kubernetes 1.6 版本以后支持，大小写不敏感。建议设置为 "X-Remote-Extra-"。用来设置一个头部字段的前缀字符串，API 服务器会基于所给 前缀来查找与用户有关的一些额外信息。这些额外信息通常用于所配置的鉴权插件。API 服务器会将与所给前缀匹配的头部字段过滤出来，去掉其前缀部分，将剩余部分 转换为小写字符串并在必要时执行百分号解码后，构造新的附加信息字段键名。原来的头部字段值直接作为附加信息字段的值。

> **说明**： 在 1.13.3 版本之前（包括 1.10.7、1.9.11），附加字段的键名只能包含[HTTP 头部标签的合法字符](https://tools.ietf.org/html/rfc7230#section-3.2.6)。

例如，使用下面的配置：
```
--requestheader-username-headers=X-Remote-User
--requestheader-group-headers=X-Remote-Group
--requestheader-extra-headers-prefix=X-Remote-Extra-
```
针对所收到的如下请求：
```
GET / HTTP/1.1
X-Remote-User: fido
X-Remote-Group: dogs
X-Remote-Group: dachshunds
X-Remote-Extra-Acme.com%2Fproject: some-project
X-Remote-Extra-Scopes: openid
X-Remote-Extra-Scopes: profile
```
会生成下面的用户信息：
```
name: fido
groups:
- dogs
- dachshunds
extra:
  acme.com/project:
  - some-project
  scopes:
  - openid
  - profile
```
为了防范头部信息侦听，在请求中的头部字段被检视之前， 身份认证代理需要向 API 服务器提供一份合法的客户端证书，供后者使用所给的 CA 来执行验证。
> **警告**：不要 在不同的上下文中复用 CA 证书，除非你清楚这样做的风险是什么以及应如何保护 CA 用法的机制。
- `--requestheader-client-ca-file` 必需字段，给出 PEM 编码的证书包。在检查请求的头部字段以提取用户名信息之前，必须提供一个合法的客户端证书，且该证书要能够被所给文件中的机构所验证。
- `--requestheader-allowed-names` 可选字段，用来给出一组公共名称（CN）。如果此标志被设置，则在检视请求中的头部以提取用户信息之前，必须提供包含此列表中所给的 CN 名的、合法的客户端证书。
### 1.3 匿名请求
启用匿名请求支持之后，如果请求没有被已配置的其他身份认证方法拒绝，则被视作匿名请求（Anonymous Requests）。这类请求获得用户名 `system:anonymous` 和对应的用户组 `system:unauthenticated`。

例如，在一个配置了令牌身份认证且启用了匿名访问的服务器上，如果请求提供了非法的持有者令牌，则会返回 `401 Unauthorized` 错误。如果请求没有提供持有者令牌，则被视为匿名请求。

在 `1.5.1-1.5.x` 版本中，匿名访问默认情况下是被禁用的，可以通过为 API 服务器设定 `--anonymous-auth=true` 来启用。

在 1.6 及之后版本中，如果所使用的鉴权模式不是 `AlwaysAllow`，则匿名访问默认是被启用的，但也可向 API Server 传递 `--anonymous-auth=false` 选项来禁用匿名访问。从 1.6 版本开始，`ABAC` 和 `RBAC` 鉴权模块要求对 `system:anonymous` 用户或者 `system:unauthenticated` 用户组执行显式的权限判定，所以之前的遗留的为 `*` 用户或 `*` 用户组赋予访问权限的策略规则都不再包含匿名用户。
### 1.4 用户伪装
一个用户可以通过伪装（Impersonation）头部字段来以另一个用户的身份执行操作。使用这一能力，你可以手动重载请求被身份认证所识别出来的用户信息。例如，管理员可以使用这一功能特性来临时伪装成另一个用户，查看请求是否被拒绝，从而调试鉴权策略中的问题，

带伪装的请求首先会被身份认证识别为发出请求的用户，之后会切换到使用被伪装的用户 的用户信息。
- 用户发起 API 调用时 同时 提供自身的凭据和伪装头部字段信息
- API 服务器对用户执行身份认证
- API 服务器确认通过认证的用户具有伪装特权
- 请求用户的信息被替换成伪装字段的值
- 评估请求，鉴权组件针对所伪装的用户信息执行操作

以下 HTTP 头部字段可用来执行伪装请求：
- `Impersonate-User`：要伪装成的用户名
- `Impersonate-Group`：要伪装成的用户组名。可以多次指定以设置多个用户组。 可选字段；要求 "Impersonate-User" 必须被设置。
- `Impersonate-Extra-<附加名称>`：一个动态的头部字段，用来设置与用户相关的附加字段。 此字段可选；要求 "Impersonate-User" 被设置。为了能够以一致的形式保留，<附加名称>部分必须是小写字符，如果有任何字符不是[合法的 HTTP 头部标签字符](https://tools.ietf.org/html/rfc7230#section-3.2.6)， 则必须是 utf8 字符，且转换为[百分号编码](https://tools.ietf.org/html/rfc3986#section-2.1)。
> **说明**： 在 1.11.3 版本之前（以及 1.10.7、1.9.11），<附加名称> 只能包含 [合法的 HTTP 头部标签字符](https://tools.ietf.org/html/rfc7230#section-3.2.6)。

头部字段集合的示例：
```
Impersonate-User: jane.doe@example.com
Impersonate-Group: developers
Impersonate-Group: admins
Impersonate-Extra-dn: cn=jane,ou=engineers,dc=example,dc=com
Impersonate-Extra-acme.com%2Fproject: some-project
Impersonate-Extra-scopes: view
Impersonate-Extra-scopes: development
```
在使用 kubectl 时，可以使用 `--as` 标志来配置 `Impersonate-User` 头部字段值， 使用 `--as-group` 标志配置 `Impersonate-Group` 头部字段值。
```
kubectl drain mynode

Error from server (Forbidden): User "clark" cannot get nodes at the cluster scope. (get nodes mynode)
```
设置 `--as` 和 `--as-group` 标志：
```
kubectl drain mynode --as=superman --as-group=system:masters
node/mynode cordoned
node/mynode drained
```
要伪装成某个用户、某个组或者设置附加字段，执行伪装操作的用户必须具有对所伪装的 类别（“user”、“group” 等）执行 “impersonate” 动词操作的能力。 对于启用了 `RBAC` 鉴权插件的集群，下面的 ClusterRole 封装了设置用户和组伪装字段 所需的规则：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: impersonator
rules:
- apiGroups: [""]
  resources: ["users", "groups", "serviceaccounts"]
  verbs: ["impersonate"]
```
附加字段会被作为 userextras 资源的子资源来执行权限评估。 如果要允许用户为附加字段 “scopes” 设置伪装头部，该用户需要被授予以下规则：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: scopes-impersonator
rules:
# 可以设置 "Impersonate-Extra-scopes" 头部
- apiGroups: ["authentication.k8s.io"]
  resources: ["userextras/scopes"]
  verbs: ["impersonate"]
```
你也可以通过约束资源可能对应的 `resourceNames` 限制伪装头部的取值：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: limited-impersonator
rules:
# 可以伪装成用户 "jane.doe@example.com"
- apiGroups: [""]
  resources: ["users"]
  verbs: ["impersonate"]
  resourceNames: ["jane.doe@example.com"]

# 可以伪装成用户组 "developers" 和 "admins"
- apiGroups: [""]
  resources: ["groups"]
  verbs: ["impersonate"]
  resourceNames: ["developers","admins"]

# 可以将附加字段 "scopes" 伪装成 "view" 和 "development"
- apiGroups: ["authentication.k8s.io"]
  resources: ["userextras/scopes"]
  verbs: ["impersonate"]
  resourceNames: ["view", "development"]
```
### 1.5 client-go 凭据插件
**FEATURE STATE: Kubernetes v1.11 [beta]**

k8s.io/client-go 及使用它的工具（如 kubectl 和 kubelet）可以执行某个外部 命令来获得用户的凭据信息。

这一特性的目的是便于客户端与 k8s.io/client-go 并不支持的身份认证协议（LDAP、 Kerberos、OAuth2、SAML 等）继承。 插件实现特定于协议的逻辑，之后返回不透明的凭据以供使用。几乎所有的凭据插件使用场景中都需要在服务器端存在一个支持 [Webhook 令牌身份认证组件](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#webhook-token-authentication)的模块，负责解析客户端插件所生成的凭据格式。

**示例应用场景**
在一个假想的应用场景中，某组织运行这一个外部的服务，能够将特定用户的已签名的 令牌转换成 LDAP 凭据。此服务还能够对 [Webhook 令牌身份认证组件](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#webhook-token-authentication)的请求做出响应以 验证所提供的令牌。用户需要在自己的工作站上安装一个凭据插件。

要对 API 服务器认证身份时：
- 用户发出 `kubectl` 命令。
- 凭据插件提示用户输入 LDAP 凭据，并与外部服务交互，获得令牌。
- 凭据插件将令牌返回该 client-go，后者将其用作持有者令牌提交给 API 服务器。
- API 服务器使用 [Webhook 令牌身份认证组件](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#webhook-token-authentication)向外部服务发出 `TokenReview` 请求。
- 外部服务检查令牌上的签名，返回用户的用户名和用户组信息。

**配置**
凭据插件通过 [kubectl 配置文件](https://kubernetes.io/zh/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)来作为 user 字段的一部分设置。
```
apiVersion: v1
kind: Config
users:
- name: my-user
  user:
    exec:
      # 要执行的命令。必需。
      command: "example-client-go-exec-plugin"

      # 解析 ExecCredentials 资源时使用的 API 版本。必需。
      #
      # 插件返回的 API 版本必需与这里列出的版本匹配。
      #
      # 要与支持多个版本的工具（如 client.authentication.k8sio/v1alpha1）集成，
      # 可以设置一个环境变量或者向工具传递一个参数标明 exec 插件所期望的版本。
      apiVersion: "client.authentication.k8s.io/v1beta1"

      # 执行此插件时要设置的环境变量。可选字段。
      env:
      - name: "FOO"
        value: "bar"

      # 执行插件时要传递的参数。可选字段。
      args:
      - "arg1"
      - "arg2"

      # 当可执行文件不存在时显示给用户的文本。可选的。
      installHint: |
        需要 example-client-go-exec-plugin 来在当前集群上执行身份认证。可以通过以下命令安装：

        MacOS: brew install example-client-go-exec-plugin

        Ubuntu: apt-get install example-client-go-exec-plugin

        Fedora: dnf install example-client-go-exec-plugin

        ...        

      # 是否使用 KUBERNETES_EXEC_INFO 环境变量的一部分向这个 exec 插件
      # 提供集群信息（可能包含非常大的 CA 数据）
      provideClusterInfo: true
clusters:
- name: my-cluster
  cluster:
    server: "https://172.17.4.100:6443"
    certificate-authority: "/etc/kubernetes/ca.pem"
    extensions:
    - name: client.authentication.k8s.io/exec # 为每个集群 exec 配置保留的扩展名
      extension:
        arbitrary: config
        this: 在设置 provideClusterInfo 时可通过环境变量 KUBERNETES_EXEC_INFO 指定
        you: ["can", "put", "anything", "here"]
contexts:
- name: my-cluster
  context:
    cluster: my-cluster
    user: my-user
current-context: my-cluster
```
解析相对命令路径时，kubectl 将其视为与配置文件比较而言的相对路径。如果 KUBECONFIG 被设置为 `/home/jane/kubeconfig`，而 `exec` 命令为 `./bin/example-client-go-exec-plugin`，则要执行的可执行文件为 `/home/jane/bin/example-client-go-exec-plugin`。
```
- name: my-user
  user:
    exec:
      # 对 kubeconfig 目录而言的相对路径
      command: "./bin/example-client-go-exec-plugin"
      apiVersion: "client.authentication.k8s.io/v1beta1"
```
**输出和输出格式**
所执行的命令会在 `stdout` 打印 `ExecCredential` 对象。`k8s.io/client-go` 使用 `status` 中返回的凭据信息向 Kubernetes API 服务器 执行身份认证。

在交互式会话中运行时，`stdin` 是直接暴露给插件使用的。 插件应该使用 `TTY check` 来确定是否适合用交互方式请求用户输入。

与使用持有者令牌凭据，插件在 `ExecCredential` 的状态中返回一个令牌：
```
{
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "kind": "ExecCredential",
  "status": {
    "token": "my-bearer-token"
  }
}
```
另一种方案是，返回 PEM 编码的客户端证书和密钥，以便执行 TLS 客户端身份认证。如果插件在后续调用中返回了不同的证书或密钥，`k8s.io/client-go` 会终止其与服务器的连接，从而强制执行新的 TLS 握手过程。

如果指定了这种方式，则 `clientKeyData` 和 `clientCertificateData` 字段都必需存在。

`clientCertificateData` 字段可能包含一些要发送给服务器的中间证书（Intermediate Certificates）。
```
{
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "kind": "ExecCredential",
  "status": {
    "clientCertificateData": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----",
    "clientKeyData": "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
  }
}
```
作为一种可选方案，响应中还可以包含以 RFC3339 时间戳格式给出的证书到期时间。证书到期时间的有无会有如下影响：
- 如果响应中包含了到期时间，持有者令牌和 TLS 凭据会被缓存，直到到期期限到来、 或者服务器返回 401 HTTP 状态码，或者进程退出。
- 如果未指定到期时间，则持有者令牌和 TLS 凭据会被缓存，直到服务器返回 401 HTTP 状态码或者进程退出。
```
{
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "kind": "ExecCredential",
  "status": {
    "token": "my-bearer-token",
    "expirationTimestamp": "2018-03-05T17:30:20-08:00"
  }
}
```
调用此插件时可以选择性地设置环境变量 KUBERNETES_EXEC_INFO。 该变量包含了此插件获取凭据所针对的集群信息。此信息可用于执行群集特定的凭据获取逻辑。 为了启用此行为，必须在 [kubeconfig](https://kubernetes.io/zh/docs/concepts/configuration/organize-cluster-access-kubeconfig/) 中的 exec user 字段上设置provideClusterInfo字段。 下面是上述 KUBERNETES_EXEC_INFO 环境变量的示例。
```
{
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "kind": "ExecCredential",
  "spec": {
    "cluster": {
      "server": "https://172.17.4.100:6443",
      "certificate-authority-data": "LS0t...",
      "config": {
        "arbitrary": "config",
        "this": "在设置 provideClusterInfo 时可通过环境变量 KUBERNETES_EXEC_INFO 指定",
        "you": ["can", "put", "anything", "here"]
      }
    }
  }
}
```
## 2. 准入控制器
## 3. 鉴权
### 3.0 鉴权概述
了解有关 Kubernetes 鉴权的更多信息，包括使用支持的鉴权模块创建策略的详细信息。

在 Kubernetes 中，你必须在鉴权（授予访问权限）之前进行身份验证（登录），有关身份验证的信息，请参阅[访问控制概述](https://kubernetes.io/zh/docs/concepts/security/controlling-access/).

Kubernetes 期望请求中存在 REST API 常见的属性。 这意味着 Kubernetes 鉴权适用于现有的组织范围或云提供商范围的访问控制系统，除了 Kubernetes API 之外，它还可以处理其他 API。
#### 3.0.1 确定是允许还是拒绝请求
Kubernetes 使用 API 服务器对 API 请求进行鉴权。它根据所有策略评估所有请求属性来决定允许或拒绝请求。一个 API 请求的所有部分都必须被某些策略允许才能继续，这意味着默认情况下拒绝权限。

（尽管 Kubernetes 使用 API 服务器，但是依赖于特定对象种类的特定字段的访问控制和策略由准入控制器处理。）

当系统配置了多个鉴权模块时，Kubernetes 将按顺序使用每个模块。 如果任何鉴权模块批准或拒绝请求，则立即返回该决定，并且不会与其他鉴权模块协商。 如果所有模块对请求没有意见，则拒绝该请求。 被拒绝响应返回 HTTP 状态代码 403。
#### 3.0.1 审查你的请求属性
Kubernetes 仅审查以下 API 请求属性：
- **用户** - 身份验证期间提供的 `user` 字符串。
- **组** - 经过身份验证的用户所属的组名列表。
- **额外信息** - 由身份验证层提供的任意字符串键到字符串值的映射。
- **API** - 指示请求是否针对 API 资源。
- **请求路径** - 各种非资源端点的路径，如 `/api` 或 `/healthz`。
- **API 请求动词** - API 动词 `get`、`list`、`create`、`update`、`patch`、`watch`、 `proxy`、`redirect`、`delete` 和 `deletecollection` 用于资源请求。要确定资源 API 端点的请求动词，请参阅[确定请求动词](https://kubernetes.io/zh/docs/reference/access-authn-authz/authorization/#determine-the-request-verb)。
- **HTTP 请求动词** - HTTP 动词 `get`、`post`、`put` 和 `delete` 用于非资源请求。
- **Resource** - 正在访问的资源的 ID 或名称（仅限资源请求）- 对于使用 `get`、`update`、`patch` 和 `delete` 动词的资源请求，你必须提供资源名称。
- **子资源** - 正在访问的子资源（仅限资源请求）。
- **名字空间** - 正在访问的对象的名称空间（仅适用于名字空间资源请求）。
- **API 组** - 正在访问的 API 组 （仅限资源请求）。空字符串表示[核心 API 组](https://kubernetes.io/zh/docs/reference/using-api/#api-groups)。
#### 3.0.3 确定请求动词
非资源请求

对于 `/api/v1/...` 或 `/apis/<group>/<version>/...` 之外的端点的请求被 视为“非资源请求（Non-Resource Requests）”，并使用该请求的 HTTP 方法的 小写形式作为其请求动词。例如，对 `/api` 或 `/healthz` 这类端点的 `GET` 请求将使用 `get` 作为其动词。

**资源请求**

要确定对资源 API 端点的请求动词，需要查看所使用的 HTTP 动词以及该请求是针对单个资源还是一组资源：
HTTP 动词|请求动词
--------|--------
POST|create
GET, HEAD|get（针对单个资源）、list（针对集合）
PUT|update
PATCH|patch
DELETE|delete（针对单个资源）、deletecollection（针对集合）

Kubernetes 有时使用专门的动词以对额外的权限进行鉴权。例如：
- [PodSecurityPolicy](https://kubernetes.io/zh/docs/concepts/policy/pod-security-policy/)
  + `policy` API 组中 `podsecuritypolicies` 资源使用 `use` 动词
- [RBAC](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#privilege-escalation-prevention-and-bootstrapping)
  + 对 `rbac.authorization.k8s.io` API 组中 `roles` 和 `clusterroles` 资源的 `bind` 和 `escalate` 动词
- [身份认证](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/)
  + 对核心 API 组中 `users`、`groups` 和 `serviceaccounts` 以及 `authentication.k8s.io` API 组中的 `userextras` 所使用的 `impersonate` 动词
#### 3.0.4 鉴权模块
- **Node** - 一个专用鉴权组件，根据调度到 kubelet 上运行的 Pod 为 kubelet 授予权限。了解有关使用节点鉴权模式的更多信息，请参阅[节点鉴权](https://kubernetes.io/zh/docs/reference/access-authn-authz/node/)。
- **ABAC** - 基于属性的访问控制（ABAC）定义了一种访问控制范型，通过使用将属性组合 在一起的策略，将访问权限授予用户。策略可以使用任何类型的属性（用户属性、资源属性、 对象，环境属性等）。要了解有关使用 ABAC 模式的更多信息，请参阅 [ABAC 模式](https://kubernetes.io/zh/docs/reference/access-authn-authz/abac/)。
- **RBAC** - 基于角色的访问控制（RBAC）是一种基于企业内个人用户的角色来管理对 计算机或网络资源的访问的方法。在此上下文中，权限是单个用户执行特定任务的能力， 例如查看、创建或修改文件。要了解有关使用 RBAC 模式的更多信息，请参阅 [RBAC 模式](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/)。
  + 被启用之后，RBAC（基于角色的访问控制）使用 `rbac.authorization.k8s.io` API 组来驱动鉴权决策，从而允许管理员通过 Kubernetes API 动态配置权限策略。
  + 要启用 RBAC，请使用 `--authorization-mode = RBAC` 启动 API 服务器。
- **Webhook** - WebHook 是一个 HTTP 回调：发生某些事情时调用的 HTTP POST；通过 HTTP POST 进行简单的事件通知。实现 WebHook 的 Web 应用程序会在发生某些事情时将消息发布到 URL。要了解有关使用 Webhook 模式的更多信息，请参阅 [Webhook 模式](https://kubernetes.io/zh/docs/reference/access-authn-authz/webhook/)。

**检查 API 访问**
kubectl 提供 `auth can-i` 子命令，用于快速查询 API 鉴权。该命令使用 `SelfSubjectAccessReview` API 来确定当前用户是否可以执行给定操作，无论使用何种鉴权模式该命令都可以工作。
```
kubectl auth can-i create deployments --namespace dev
yes
kubectl auth can-i create deployments --namespace prod
no
```
管理员可以将此与[用户扮演](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#user-impersonation)结合使用，以确定其它用户可以执行的操作。
```
kubectl auth can-i list secrets --namespace dev --as dave
no
```
`SelfSubjectAccessReview` 是 `authorization.k8s.io` API 组的一部分，它将 API 服务器鉴权公开给外部服务。该组中的其它资源包括：
- `SubjectAccessReview` - 对任意用户的访问进行评估，而不仅仅是当前用户。 当鉴权决策被委派给 API 服务器时很有用。例如，kubelet 和扩展 API 服务器使用它来确定用户对自己的 API 的访问权限。
- `LocalSubjectAccessReview` - 与 `SubjectAccessReview` 类似，但仅限于特定的名字空间。
- `SelfSubjectRulesReview` - 返回用户可在名字空间内执行的操作集的审阅。用户可以快速汇总自己的访问权限，或者用于 UI 中的隐藏/显示动作。

可以通过创建普通的 Kubernetes 资源来查询这些 API，其中返回对象的响应 "status" 字段是查询的结果。
```
kubectl create -f - -o yaml << EOF
apiVersion: authorization.k8s.io/v1
kind: SelfSubjectAccessReview
spec:
  resourceAttributes:
    group: apps
    name: deployments
    verb: create
    namespace: dev
EOF
```
生成的 `SelfSubjectAccessReview` 为：
```
apiVersion: authorization.k8s.io/v1
kind: SelfSubjectAccessReview
metadata:
  creationTimestamp: null
spec:
  resourceAttributes:
    group: apps
    name: deployments
    namespace: dev
    verb: create
status:
  allowed: true
  denied: false
```
#### 3.0.5 为你的鉴权模块设置参数
你必须在策略中包含一个参数标志，以指明你的策略包含哪个鉴权模块：

可以使用的参数有：
+ `--authorization-mode=ABAC` 基于属性的访问控制（ABAC）模式允许你 使用本地文件配置策略。
+ `--authorization-mode=RBAC` 基于角色的访问控制（RBAC）模式允许你使用 Kubernetes API 创建和存储策略。
+ `--authorization-mode=Webhook` WebHook 是一种 HTTP 回调模式，允许你使用远程 REST 端点管理鉴权。
+ `--authorization-mode=Node` 节点鉴权是一种特殊用途的鉴权模式，专门对 kubelet 发出的 API 请求执行鉴权。
+ `--authorization-mode=AlwaysDeny` 该标志阻止所有请求。仅将此标志用于测试。
+ `--authorization-mode=AlwaysAllow` 此标志允许所有请求。仅在你不需要 API 请求 的鉴权时才使用此标志。
  
你可以选择多个鉴权模块。模块按顺序检查，以便较靠前的模块具有更高的优先级来允许或拒绝请求。
#### 3.0.6 通过创建 Pod 提升权限
能够在名字空间中创建 Pod 的用户可能会提升其在该名字空间内的权限。 他们可以创建在该名字空间内访问其权限的 Pod。 他们可以创建 Pod 访问用户自己无法读取的 Secret，或者在具有不同/更高权限的 服务帐户下运行的 Pod 。

> **注意**：
> 系统管理员在授予对 Pod 创建的访问权限时要小心。 被授予在名字空间中创建 Pod（或创建 Pod 的控制器）的权限的用户可以： 读取名字空间中的所有 Secret；读取名字空间中的所有 ConfigMap； 并模拟名字空间中的任意服务账号并执行账号可以执行的任何操作。无论采用何种鉴权方式，这都适用。
### 3.1 基于角色的访问控制
基于角色（Role）的访问控制（RBAC）是一种基于组织中用户的角色来调节控制对计算机或网络资源的访问的方法。

RBAC 鉴权机制使用 `rbac.authorization.k8s.io` API 组来驱动鉴权决定，允许你通过 Kubernetes API 动态配置策略。

要启用 `RBAC`，在启动 API 服务器时将 `--authorization-mode` 参数设置为一个逗号分隔的列表并确保其中包含 `RBAC`。
```
kube-apiserver --authorization-mode=Example,RBAC --<其他选项> --<其他选项>
```
#### 3.1.1 API 对象
RBAC API 声明了四种 Kubernetes 对象：`Role`、`ClusterRole`、`RoleBinding` 和 `ClusterRoleBinding`。你可以像使用其他 Kubernetes 对象一样， 通过类似 `kubectl` 这类工具[描述对象](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/kubernetes-objects/#understanding-kubernetes-objects), 或修补对象。
> **注意**：这些对象在设计时即实施了一些访问限制。如果你在学习过程中对集群做了更改，请参考[避免特权提升和引导](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#privilege-escalation-prevention-and-bootstrapping)一节，以了解这些限制会以怎样的方式阻止你做出修改。
##### Role 和 ClusterRole
RBAC 的 Role 或 ClusterRole 中包含一组代表相关权限的规则。这些权限是纯粹累加的（不存在拒绝某操作的规则）。

Role 总是用来在某个名字空间内设置访问权限；在你创建 Role 时，你必须指定该 Role 所属的名字空间。

与之相对，ClusterRole 则是一个集群作用域的资源。这两种资源的名字不同（Role 和 ClusterRole）是因为 Kubernetes 对象要么是名字空间作用域的，要么是集群作用域的，不可两者兼具。

ClusterRole 有若干用法。你可以用它来：
1. 定义对某名字空间域对象的访问权限，并将在各个名字空间内完成授权；
2. 为名字空间作用域的对象设置访问权限，并跨所有名字空间执行授权；
3. 为集群作用域的资源定义访问权限。

如果你希望在名字空间内定义角色，应该使用 Role；如果你希望定义集群范围的角色，应该使用 ClusterRole。

**Role 示例**
下面是一个位于 "default" 名字空间的 Role 的示例，可用来授予对 pods 的读访问权限：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" 标明 core API 组
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```
##### ClusterRole 示例
ClusterRole 可以和 Role 相同完成授权。 因为 ClusterRole 属于集群范围，所以它也可以为以下资源授予访问权限：
- 集群范围资源（比如 节点（Node））
- 非资源端点（比如 `/healthz`）
- 跨名字空间访问的名字空间作用域的资源（如 Pods），比如，你可以使用 ClusterRole 来允许某特定用户执行` kubectl get pods --all-namespaces`

下面是一个 ClusterRole 的示例，可用来为任一特定名字空间中的 Secret 授予读访问权限， 或者跨名字空间的访问权限（取决于该角色是如何[绑定](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding)的）：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" 被忽略，因为 ClusterRoles 不受名字空间限制
  name: secret-reader
rules:
- apiGroups: [""]
  # 在 HTTP 层面，用来访问 Secret 对象的资源的名称为 "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```
Role 或 ClusterRole 对象的名称必须是合法的[路径区段名称](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/names#path-segment-names)。

##### RoleBinding 和 ClusterRoleBinding
角色绑定（Role Binding）是将角色中定义的权限赋予一个或者一组用户。它包含若干**主体**（用户、组或服务账户）的列表和对这些主体所获得的角色的引用。 RoleBinding 在指定的名字空间中执行授权，而 ClusterRoleBinding 在集群范围执行授权。

一个 RoleBinding 可以引用同一的名字空间中的任何 Role。 或者，一个 RoleBinding 可以引用某 ClusterRole 并将该 ClusterRole 绑定到 RoleBinding 所在的名字空间。如果你希望将某 ClusterRole 绑定到集群中所有名字空间，你要使用 ClusterRoleBinding。

RoleBinding 或 ClusterRoleBinding 对象的名称必须是合法的[路径区段名称](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/names#path-segment-names)。

**RoleBinding 示例**
下面的例子中的 RoleBinding 将 "pod-reader" Role 授予在 "default" 名字空间中的用户 "jane"。 这样，用户 "jane" 就具有了读取 "default" 名字空间中 pods 的权限。
```
apiVersion: rbac.authorization.k8s.io/v1
# 此角色绑定允许 "jane" 读取 "default" 名字空间中的 Pods
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# 你可以指定不止一个“subject（主体）”
- kind: User
  name: jane # "name" 是不区分大小写的
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" 指定与某 Role 或 ClusterRole 的绑定关系
  kind: Role # 此字段必须是 Role 或 ClusterRole
  name: pod-reader     # 此字段必须与你要绑定的 Role 或 ClusterRole 的名称匹配
  apiGroup: rbac.authorization.k8s.io
```
RoleBinding 也可以引用 ClusterRole，以将对应 ClusterRole 中定义的访问权限授予 RoleBinding 所在名字空间的资源。这种引用使得你可以跨整个集群定义一组通用的角色， 之后在多个名字空间中复用。

例如，尽管下面的 RoleBinding 引用的是一个 ClusterRole，"dave"（这里的主体， 不区分大小写）只能访问 "development" 名字空间中的 Secrets 对象，因为 RoleBinding 所在的名字空间（由其 metadata 决定）是 "development"。
```
apiVersion: rbac.authorization.k8s.io/v1
# 此角色绑定使得用户 "dave" 能够读取 "default" 名字空间中的 Secrets
# 你需要一个名为 "secret-reader" 的 ClusterRole
kind: RoleBinding
metadata:
  name: read-secrets
  # RoleBinding 的名字空间决定了访问权限的授予范围。
  # 这里仅授权在 "development" 名字空间内的访问权限。
  namespace: development
subjects:
- kind: User
  name: dave # 'name' 是不区分大小写的
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

**ClusterRoleBinding 示例**
要跨整个集群完成访问权限的授予，你可以使用一个 ClusterRoleBinding。 下面的 ClusterRoleBinding 允许 "manager" 组内的所有用户访问任何名字空间中的 Secrets。
```
apiVersion: rbac.authorization.k8s.io/v1
# 此集群角色绑定允许 “manager” 组中的任何人访问任何名字空间中的 secrets
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager # 'name' 是不区分大小写的
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```
创建了绑定之后，你不能再修改绑定对象所引用的 `Role` 或 `ClusterRole`。 试图改变绑定对象的 `roleRef` 将导致合法性检查错误。如果你想要改变现有绑定对象中 `roleRef` 字段的内容，必须删除重新创建绑定对象。

这种限制有两个主要原因：
- 针对不同角色的绑定是完全不一样的绑定。要求通过删除/重建绑定来更改 `roleRef`, 这样可以确保要赋予绑定的所有主体会被授予新的角色（而不是在允许修改 `roleRef` 的情况下导致所有现有主体未经验证即被授予新角色对应的权限）。
- 将 `roleRef` 设置为不可以改变，这使得可以为用户授予对现有绑定对象的 `update` 权限，这样可以让他们管理主体列表，同时不能更改被授予这些主体的角色。

命令 `kubectl auth reconcile` 可以创建或者更新包含 RBAC 对象的清单文件， 并且在必要的情况下删除和重新创建绑定对象，以改变所引用的角色。更多相关信息请参照[命令用法和示例](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#kubectl-auth-reconcile)
##### 对资源的引用
在 Kubernetes API 中，大多数资源都是使用对象名称的字符串表示来呈现与访问的。 例如，对于 Pod 应使用 "pods"。RBAC 使用对应 API 端点的 URL 中呈现的名字来引用资源。有一些 Kubernetes API 涉及 **子资源（subresource）**，例如 Pod 的日志。对 Pod 日志的请求看起来像这样：
```
GET /api/v1/namespaces/{namespace}/pods/{name}/log
```
在这里，`pods` 对应名字空间作用域的 Pod 资源，而 `log` 是 `pods` 的子资源。 在 RBAC 角色表达子资源时，使用斜线（/）来分隔资源和子资源。要允许某主体读取 `pods` 同时访问这些 Pod 的 `log` 子资源，你可以这么写：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
```
对于某些请求，也可以通过 `resourceNames` 列表按名称引用资源。在指定时，可以将请求限定为资源的单个实例。下面的例子中限制可以 "get" 和 "update" 一个名为 `my-configmap` 的 `ConfigMap`：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: configmap-updater
rules:
- apiGroups: [""]
  # 在 HTTP 层面，用来访问 ConfigMap 的资源的名称为 "configmaps"
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]
```
> **说明**：你不能针对 `create` 或者 `deletecollection` 请求来实施 `resourceName` 限制。 对于 `create` 操作而言，这是因为在鉴权时还不知道对象名称。
##### 聚合的 ClusterRole
你可以将若干 ClusterRole 聚合（Aggregate） 起来，形成一个复合的 ClusterRole。某个控制器作为集群控制面的一部分会监视带有 `aggregationRule` 的 ClusterRole 对象集合。`aggregationRule` 为控制器定义一个标签选择算符供后者匹配应该组合到当前 ClusterRole 的 `roles` 字段中的 ClusterRole 对象。

下面是一个聚合 ClusterRole 的示例：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
rules: [] # 控制面自动填充这里的规则
```
如果你创建一个与某现有聚合 ClusterRole 的标签选择算符匹配的 ClusterRole，这一变化会触发新的规则被添加到聚合 ClusterRole 的操作。下面的例子中，通过创建一个标签同样为 `rbac.example.com/aggregate-to-monitoring: true` 的 ClusterRole，新的规则可被添加到 "monitoring" ClusterRole 中。
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-endpoints
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
# 当你创建 "monitoring-endpoints" ClusterRole 时，
# 下面的规则会被添加到 "monitoring" ClusterRole 中
rules:
- apiGroups: [""]
  resources: ["services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
```
默认的面向用户的角色 使用 ClusterRole 聚合。这使得作为集群管理员的你可以为扩展默认规则，包括为定制资源设置规则，比如通过 CustomResourceDefinitions 或聚合 API 服务器提供的定制资源。

例如，下面的 ClusterRoles 让默认角色 "admin" 和 "edit" 拥有管理自定义资源 "CronTabs" 的权限， "view" 角色对 CronTab 资源拥有读操作权限。你可以假定 CronTab 对象在 API 服务器所看到的 URL 中被命名为 "crontabs"。
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aggregate-cron-tabs-edit
  labels:
    # 添加以下权限到默认角色 "admin" 和 "edit" 中
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
rules:
- apiGroups: ["stable.example.com"]
  resources: ["crontabs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aggregate-cron-tabs-view
  labels:
    # 添加以下权限到 "view" 默认角色中
    rbac.authorization.k8s.io/aggregate-to-view: "true"
rules:
- apiGroups: ["stable.example.com"]
  resources: ["crontabs"]
  verbs: ["get", "list", "watch"]
```

**Role 示例**
以下示例均为从 Role 或 CLusterRole 对象中截取出来，我们仅展示其 `rules` 部分。

允许读取在核心 API 组下的 "Pods"：
```
rules:
- apiGroups: [""]
  # 在 HTTP 层面，用来访问 Pod 的资源的名称为 "pods"
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```
允许读/写在 "extensions" 和 "apps" API 组中的 Deployment（在 HTTP 层面，对应 URL 中资源部分为 "deployments"）：
```
rules:
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
允许读取核心 API 组中的 "pods" 和读/写 "batch" 或 "extensions" API 组中的 "jobs"：
```
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```
允许读取名称为 "my-config" 的 ConfigMap（需要通过 RoleBinding 绑定以限制为某名字空间中特定的 ConfigMap）：
```
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-config"]
  verbs: ["get"]
```
允许读取在核心组中的 "nodes" 资源（因为 Node 是集群作用域的，所以需要 ClusterRole 绑定到 ClusterRoleBinding 才生效）：
```
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```
允许针对非资源端点 /healthz 和其子路径上发起 GET 和 POST 请求（必须在 ClusterRole 绑定 ClusterRoleBinding 才生效）：
```
rules:
  - nonResourceURLs: ["/healthz", "/healthz/*"] # nonResourceURL 中的 '*' 是一个全局通配符
    verbs: ["get", "post"]
```
##### 对主体的引用
RoleBinding 或者 ClusterRoleBinding 可绑定角色到某**主体（Subject）**上。 主体可以是组，用户或者服务账户。

Kubernetes 用字符串来表示用户名。用户名可以是普通的用户名，像 "alice"；或者是邮件风格的名称，如 "bob@example.com"，或者是以字符串形式表达的数字 ID。你作为 Kubernetes 管理员负责配置[身份认证模块](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/)以便后者能够生成你所期望的格式的用户名。
> **注意**：前缀 `system:` 是 Kubernetes 系统保留的，所以你要确保所配置的用户名或者组名不能出现上述 `system:` 前缀。除了对前缀的限制之外，RBAC 鉴权系统不对用户名格式作任何要求。

在 Kubernetes 中，鉴权模块提供用户组信息。与用户名一样，用户组名也用字符串来表示，而且对该字符串没有格式要求，只是不能使用保留的前缀 `system:`。

[服务账户](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-service-account/)的用户名前缀为 `system:serviceaccount:`，属于前缀为 `system:serviceaccounts:` 的用户组。
> **说明**：
> - system:serviceaccount: （单数）是用于服务账户用户名的前缀；
> - system:serviceaccounts: （复数）是用于服务账户组名的前缀。

**RoleBinding 示例**
下面示例是 `RoleBinding` 中的片段，仅展示其 `subjects` 的部分。

对于名称为 `alice@example.com` 的用户：
```
subjects:
- kind: User
  name: "alice@example.com"
  apiGroup: rbac.authorization.k8s.io
```
对于名称为 `frontend-admins` 的用户组：
```
subjects:
- kind: Group
  name: "frontend-admins"
  apiGroup: rbac.authorization.k8s.io
```
对于 kube-system 名字空间中的默认服务账户：
```
subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
```
对于任何名称空间中的 "qa" 组中所有的服务账户：
```
subjects:
- kind: Group
  name: system:serviceaccounts:qa
  apiGroup: rbac.authorization.k8s.io
```
对于 "development" 名称空间中 "dev" 组中的所有服务帐户：
```
subjects:
- kind: Group
  name: system:serviceaccounts:dev
  apiGroup: rbac.authorization.k8s.io
  namespace: development
```
对于在任何名字空间中的服务账户：
```
subjects:
- kind: Group
  name: system:serviceaccounts
  apiGroup: rbac.authorization.k8s.io
```
对于所有已经过认证的用户：
```
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
```
对于所有未通过认证的用户：
```
subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```
对于所有用户：
```
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```
#### 3.1.2 默认 Roles 和 Role Bindings
API 服务器创建一组默认的 ClusterRole 和 ClusterRoleBinding 对象。这其中许多是以 `system:` 为前缀的，用以标识对应资源是直接由集群控制面管理的。所有的默认 ClusterRole 和 ClusterRoleBinding 都有 `kubernetes.io/bootstrapping=rbac-defaults` 标签。
> **注意**：在修改名称包含 `system:` 前缀的 ClusterRole 和 ClusterRoleBinding 时要格外小心。对这些资源的更改可能导致集群无法继续工作。
##### 自动协商
在每次启动时，API 服务器都会更新默认 ClusterRole 以添加缺失的各种权限，并更新默认的 ClusterRoleBinding 以增加缺失的的各类主体。这种自动协商机制允许集群去修复一些不小心发生的修改，并且有助于保证角色和角色绑定在新的发行版本中有权限或主体变更时仍然保持最新。

如果要禁止此功能，请将默认 ClusterRole 以及 ClusterRoleBinding 的 `rbac.authorization.kubernetes.io/autoupdate` 注解设置成 `false`。 注意，缺少默认权限和角色绑定主体可能会导致集群无法正常工作。

如果基于 RBAC 的鉴权机制被启用，则自动协商功能默认是被启用的。
##### API 发现角色
无论是经过身份验证的还是未经过身份验证的用户，默认的角色绑定都授权他们读取被认为 是可安全地公开访问的 API（ 包括 CustomResourceDefinitions）。如果要禁用匿名的未经过身份验证的用户访问，请在 API 服务器配置中中添加 `--anonymous-auth=false` 的配置选项。

通过运行命令 kubectl 可以查看这些角色的配置信息:
```
kubectl get clusterroles system:discovery -o yaml
```
> **说明**：如果你编辑该 ClusterRole，你所作的变更会被 API 服务器在重启时自动覆盖，这是通过自动协商机制完成的。要避免这类覆盖操作，要么不要手动编辑这些角色，要么禁止自动协商机制。

Kubernetes RBAC API 发现角色
**默认 ClusterRole**|**默认 ClusterRoleBinding**|**描述**
--------|--------|--------
system:basic-user|system:authenticated 组|允许用户以只读的方式去访问他们自己的基本信息。在 1.14 版本之前，这个角色在默认情况下也绑定在 system:unauthenticated 上。
system:discovery|system:authenticated 组|允许以只读方式访问 API 发现端点，这些端点用来发现和协商 API 级别。 在 1.14 版本之前，这个角色在默认情况下绑定在 system:unauthenticated 上。
system:public-info-viewer|system:authenticated 和 system:unauthenticated 组|允许对集群的非敏感信息进行只读访问，它是在 1.14 版本中引入的。
##### 面向用户的角色
一些默认的 ClusterRole 不是以前缀 system: 开头的。这些是面向用户的角色。它们包括超级用户（Super-User）角色（cluster-admin）、使用 ClusterRoleBinding 在集群范围内完成授权的角色（cluster-status）、以及使用 RoleBinding 在特定名字空间中授予的角色（admin、edit、view）。

面向用户的 ClusterRole 使用 [ClusterRole](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles) 聚合以允许管理员在这些 ClusterRole 上添加用于定制资源的规则。如果想要添加规则到 `admin`、`edit` 或者 `view`，可以创建带有以下一个或多个标签的 ClusterRole：
```
metadata:
  labels:
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
```

默认 ClusterRole|默认 ClusterRoleBinding|描述
--------|--------|--------
cluster-admin|system:masters 组|允许超级用户在平台上的任何资源上执行所有操作。当在 ClusterRoleBinding 中使用时，可以授权对集群中以及所有名字空间中的全部资源进行完全控制。当在 RoleBinding 中使用时，可以授权控制 RoleBinding 所在名字空间中的所有资源，包括名字空间本身。
admin|无|允许管理员访问权限，旨在使用 RoleBinding 在名字空间内执行授权。 如果在 RoleBinding 中使用，则可授予对名字空间中的大多数资源的读/写权限，包括创建角色和角色绑定的能力。 但是它不允许对资源配额或者名字空间本身进行写操作。
edit|无|允许对名字空间的大多数对象进行读/写操作。它不允许查看或者修改角色或者角色绑定。不过，此角色可以访问 Secret，以名字空间中任何 ServiceAccount 的身份运行 Pods，所以可以用来了解名字空间内所有服务账户的 API 访问级别。
view|无|允许对名字空间的大多数对象有只读权限。 它不允许查看角色或角色绑定。此角色不允许查看 Secrets，因为读取 Secret 的内容意味着可以访问名字空间中 ServiceAccount 的凭据信息，进而允许利用名字空间中任何 ServiceAccount 的身份访问 API（这是一种特权提升）。
##### 核心组件角色
默认 ClusterRole|默认 ClusterRoleBinding|描述
--------|--------|--------
system:kube-scheduler|system:kube-scheduler 用户|允许访问 scheduler 组件所需要的资源。
system:volume-scheduler|system:kube-scheduler 用户|允许访问 kube-scheduler 组件所需要的卷资源。
system:kube-controller-manager|system:kube-controller-manager 用户|允许访问控制器管理器 组件所需要的资源。 各个控制回路所需要的权限在控制器角色 详述。
system:node|无|允许访问 kubelet 所需要的资源，包括对所有 Secret 的读操作和对所有 Pod 状态对象的写操作。你应该使用 Node 鉴权组件 和 NodeRestriction 准入插件 而不是 system:node 角色。同时基于 kubelet 上调度执行的 Pod 来授权 kubelet 对 API 的访问。system:node 角色的意义仅是为了与从 v1.8 之前版本升级而来的集群兼容。
system:node-proxier|system:kube-proxy 用户|允许访问 kube-proxy 组件所需要的资源。
##### 其它组件角色
默认 ClusterRole|默认 ClusterRoleBinding|描述
--------|--------|--------
system:auth-delegator|无|允许将身份认证和鉴权检查操作外包出去。 这种角色通常用在插件式 API 服务器上，以实现统一的身份认证和鉴权。
system:heapster|无|为 Heapster 组件（已弃用）定义的角色。
system:kube-aggregator|无|为 kube-aggregator 组件定义的角色。
system:kube-dns|在 kube-system 名字空间中的 kube-dns 服务账户|为 kube-dns 组件定义的角色。
system:kubelet-api-admin|无|允许 kubelet API 的完全访问权限。
system:node-bootstrapper|无|允许访问执行 kubelet TLS 启动引导 所需要的资源。
system:node-problem-detector|无|为 node-problem-detector 组件定义的角色。
system:persistent-volume-provisioner|无|允许访问大部分 动态卷驱动 所需要的资源。
system:monitoring|system:monitoring 组|允许对控制平面监控端点的读取访问（例如：kube-apiserver 存活和就绪端点（/healthz、/livez、/readyz），各个健康检查端点（/healthz/*、/livez/*、/readyz/*）和 /metrics）。 请注意，各个运行状况检查端点和度量标准端点可能会公开敏感信息。
##### 内置控制器的角色
Kubernetes 控制器管理器运行内建于 Kubernetes 控制面的控制器。当使用 `--use-service-account-credentials` 参数启动时, `kube-controller-manager` 使用单独的服务账户来启动每个控制器。每个内置控制器都有相应的、前缀为 `system:controller:` 的角色。如果控制管理器启动时未设置 `--use-service-account-credentials`，它使用自己的身份凭据来运行所有的控制器，该身份必须被授予所有相关的角色。这些角色包括:
- system:controller:attachdetach-controller
- system:controller:certificate-controller
- system:controller:clusterrole-aggregation-controller
- system:controller:cronjob-controller
- system:controller:daemon-set-controller
- system:controller:deployment-controller
- system:controller:disruption-controller
- system:controller:endpoint-controller
- system:controller:expand-controller
- system:controller:generic-garbage-collector
- system:controller:horizontal-pod-autoscaler
- system:controller:job-controller
- system:controller:namespace-controller
- system:controller:node-controller
- system:controller:persistent-volume-binder
- system:controller:pod-garbage-collector
- system:controller:pv-protection-controller
- system:controller:pvc-protection-controller
- system:controller:replicaset-controller
- system:controller:replication-controller
- system:controller:resourcequota-controller
- system:controller:root-ca-cert-publisher
- system:controller:route-controller
- system:controller:service-account-controller
- system:controller:service-controller
- system:controller:statefulset-controller
- system:controller:ttl-controller
#### 3.1.3 初始化与预防权限提升
RBAC API 会阻止用户通过编辑角色或者角色绑定来提升权限。由于这一点是在 API 级别实现的，所以在 RBAC 鉴权组件未启用的状态下依然可以正常工作。
##### 对角色创建或更新的限制
只有在符合下列条件之一的情况下，你才能创建/更新角色:
1. 你已经拥有角色中包含的所有权限，且其作用域与正被修改的对象作用域相同。（对 ClusterRole 而言意味着集群范围，对 Role 而言意味着相同名字空间或者集群范围）。
2. 你被显式授权在 `rbac.authorization.k8s.io` API 组中的 `roles` 或 `clusterroles` 资源使用 `escalate` 动词。

例如，如果 user-1 没有列举集群范围所有 Secret 的权限，他将不能创建包含该权限的 ClusterRole。 若要允许用户创建/更新角色：
1. 根据需要赋予他们一个角色，允许他们根据需要创建/更新 Role 或者 ClusterRole 对象。
2. 授予他们在所创建/更新角色中包含特殊权限的权限:
  + 隐式地为他们授权（如果它们试图创建或者更改 Role 或 ClusterRole 的权限，但自身没有被授予相应权限，API 请求将被禁止）。
  + 通过允许他们在 Role 或 ClusterRole 资源上执行 `escalate` 动作显式完成授权。这里的 `roles` 和 `clusterroles` 资源包含在 `rbac.authorization.k8s.io` API 组中。
##### 对角色绑定创建或更新的限制
只有你已经具有了所引用的角色中包含的全部权限时，或者你被授权在所引用的角色上执行 `bind` 动词时，你才可以创建或更新角色绑定。这里的权限与角色绑定的作用域相同。例如，如果用户 user-1 没有列举集群范围所有 Secret 的能力，则他不可以创建 ClusterRoleBinding 引用授予该许可权限的角色。 如要允许用户创建或更新角色绑定：
1. 赋予他们一个角色，使得他们能够根据需要创建或更新 RoleBinding 或 ClusterRoleBinding 对象。
2. 授予他们绑定某特定角色所需要的许可权限：
  + 隐式授权下，可以将角色中包含的许可权限授予他们；
  + 显式授权下，可以授权他们在特定 Role （或 ClusterRole）上执行 `bind` 动词的权限。

例如，下面的 ClusterRole 和 RoleBinding 将允许用户 `user-1` 把名字空间 `user-1-namespace` 中的` admin`、`edit` 和 `view` 角色赋予其他用户：
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: role-grantor
rules:
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["rolebindings"]
  verbs: ["create"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["clusterroles"]
  verbs: ["bind"]
  # 忽略 resourceNames 意味着允许绑定任何 ClusterRole
  resourceNames: ["admin","edit","view"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: role-grantor-binding
  namespace: user-1-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: role-grantor
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: user-1
```
当启动引导第一个角色和角色绑定时，需要为初始用户授予他们尚未拥有的权限。对初始角色和角色绑定进行初始化时需要：
- 使用用户组为 `system:masters` 的凭据，该用户组由默认绑定关联到 `cluster-admin` 这个超级用户角色。
- 如果你的 API 服务器启动时启用了不安全端口（使用 `--insecure-port`）, 你也可以通过 该端口调用 API ，这样的操作会绕过身份验证或鉴权。
#### 3.1.4 一些命令行工具
##### kubectl create role
创建 Role 对象，定义在某一名字空间中的权限。例如:
- 创建名称为 "pod-reader" 的 Role 对象，允许用户对 Pods 执行 `get`、`watch` 和 `list` 操作：
  ```
  kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods
  ```
- 创建名称为 "pod-reader" 的 Role 对象并指定 `resourceNames`：
  ```
  kubectl create role pod-reader --verb=get --resource=pods --resource-name=readablepod --resource-name=anotherpod
  ```
- 创建名为 "foo" 的 Role 对象并指定 apiGroups：
  ```
  kubectl create role foo --verb=get,list,watch --resource=replicasets.apps
  ```
- 创建名为 "foo" 的 Role 对象并指定子资源权限:
  ```
  kubectl create role foo --verb=get,list,watch --resource=pods,pods/status
  ```
- 创建名为 "my-component-lease-holder" 的 Role 对象，使其具有对特定名称的 资源执行 get/update 的权限：
  ```
  kubectl create role my-component-lease-holder --verb=get,list,watch,update --resource=lease --resource-name=my-component
  ```
##### kubectl create clusterrole
创建 ClusterRole 对象。例如：
- 创建名称为 "pod-reader" 的 ClusterRole对象，允许用户对 `Pods` 对象执行 `get`、`watch` 和 `list` 操作：
  ```
  kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods
  ```
- 创建名为 "pod-reader" 的 ClusterRole 对象并指定 `resourceNames`：
  ```
  kubectl create clusterrole pod-reader --verb=get --resource=pods --resource-name=readablepod --resource-name=anotherpod
  ```
- 创建名为 "foo" 的 ClusterRole 对象并指定 apiGroups：
  ```
  kubectl create clusterrole foo --verb=get,list,watch --resource=replicasets.apps
  ```
- 创建名为 "foo" 的 ClusterRole 对象并指定子资源:
  ```
  kubectl create clusterrole foo --verb=get,list,watch --resource=pods,pods/status
  ```
- 创建名为 "foo" 的 ClusterRole 对象并指定 nonResourceURL：
  ```
  kubectl create clusterrole "foo" --verb=get --non-resource-url=/logs/*
  ```
- 创建名为 "monitoring" 的 ClusterRole 对象并指定 aggregationRule：
  ```
  kubectl create clusterrole monitoring --aggregation-rule="rbac.example.com/aggregate-to-monitoring=true"
  ```
##### kubectl create rolebinding
在特定的名字空间中对 Role 或 ClusterRole 授权。例如：
- 在名字空间 "acme" 中，将名为 `admin` 的 ClusterRole 中的权限授予名称 "bob" 的用户:
  ```
  kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=acme
  ```
- 在名字空间 "acme" 中，将名为 `view` 的 ClusterRole 中的权限授予名字空间 "acme" 中名为 `myapp` 的服务账户：
  ```
  kubectl create rolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp --namespace=acme
  ```
- 在名字空间 "acme" 中，将名为 `view` 的 ClusterRole 对象中的权限授予名字空间 "myappnamespace" 中名称为 `myapp` 的服务账户：
  ```
  kubectl create rolebinding myappnamespace-myapp-view-binding --clusterrole=view --serviceaccount=myappnamespace:myapp --namespace=acme
  ```
##### kubectl create clusterrolebinding
在整个集群（所有名字空间）中用 ClusterRole 授权。例如：
- 在整个集群范围，将名为 `cluster-admin` 的 ClusterRole 中定义的权限授予名为 "root" 用户：
  ```
  kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root
  ```
- 在整个集群范围内，将名为 `system:node-proxier` 的 ClusterRole 的权限授予名为 "system:kube-proxy" 的用户：
  ```
  kubectl create clusterrolebinding kube-proxy-binding --clusterrole=system:node-proxier --user=system:kube-proxy
  ```
- 在整个集群范围内，将名为 `view` 的 ClusterRole 中定义的权限授予 "acme" 名字空间中 名为 "myapp" 的服务账户：
  ```
  kubectl create clusterrolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp
  ```
##### kubectl auth reconcile
使用清单文件来创建或者更新 `rbac.authorization.k8s.io/v1` API 对象。

尚不存在的对象会被创建，如果对应的名字空间也不存在，必要的话也会被创建。已经存在的角色会被更新，使之包含输入对象中所给的权限。如果指定了 `--remove-extra-permissions`，可以删除额外的权限。

已经存在的绑定也会被更新，使之包含输入对象中所给的主体。如果指定了 `--remove-extra-permissions`，则可以删除多余的主体。

例如:
- 测试应用 RBAC 对象的清单文件，显示将要进行的更改：
  ```
  kubectl auth reconcile -f my-rbac-rules.yaml --dry-run
  ```
- 应用 RBAC 对象的清单文件，保留角色中的额外权限和绑定中的其他主体：
  ```
  kubectl auth reconcile -f my-rbac-rules.yaml
  ```
- 应用 RBAC 对象的清单文件, 删除角色中的额外权限和绑定中的其他主体：
  ```
  kubectl auth reconcile -f my-rbac-rules.yaml --remove-extra-subjects --remove-extra-permissions
  ```

查看 CLI 帮助获取详细的用法。
#### 3.1.5 服务账户权限
默认的 RBAC 策略为控制面组件、节点和控制器授予权限。但是不会对 kube-system 名字空间之外的服务账户授予权限。（除了授予所有已认证用户的发现权限）

这使得你可以根据需要向特定服务账户授予特定权限。细粒度的角色绑定可带来更好的安全性，但需要更多精力管理。粗粒度的授权可能导致服务账户被授予不必要的 API 访问权限（甚至导致潜在的权限提升），但更易于管理。

按从最安全到最不安全的顺序，存在以下方法：
1. 为特定应用的服务账户授予角色（最佳实践）
   这要求应用在其 Pod 规约中指定 `serviceAccountName`，并额外创建服务账户（包括通过 API、应用程序清单、`kubectl create serviceaccount` 等）。

   例如，在名字空间 "my-namespace" 中授予服务账户 "my-sa" 只读权限：
   ```
   kubectl create rolebinding my-sa-view \
    --clusterrole=view \
    --serviceaccount=my-namespace:my-sa \
    --namespace=my-namespace
   ```
2. 将角色授予某名字空间中的 "default" 服务账户
   如果某应用没有指定 `serviceAccountName`，那么它将使用 "default" 服务账户。

   > **说明**： "default" 服务账户所具有的权限会被授予给名字空间中所有未指定 `serviceAccountName` 的 Pod。

   例如，在名字空间 "my-namespace" 中授予服务账户 "default" 只读权限：
   ```
   kubectl create rolebinding default-view \
      --clusterrole=view \
      --serviceaccount=my-namespace:default \
      --namespace=my-namespace
   ```

   许多[插件组件](https://kubernetes.io/zh/docs/concepts/cluster-administration/addons/)在 `kube-system` 名字空间以 "default" 服务账户运行。要允许这些插件组件以超级用户权限运行，需要将集群的 `cluster-admin` 权限授予 `kube-system` 名字空间中的 "default" 服务账户：
   > **说明**： 启用这一配置意味着在 `kube-system` 名字空间中包含以超级用户账号来访问 API 的 Secrets。
   ```
   kubectl create clusterrolebinding add-on-cluster-admin \
      --clusterrole=cluster-admin \
      --serviceaccount=kube-system:default
   ```
3. 将角色授予名字空间中所有服务账户
   如果你想要名字空间中所有应用都具有某角色，无论它们使用的什么服务账户，可以将角色授予该名字空间的服务账户组。

   例如，在名字空间 "my-namespace" 中的只读权限授予该名字空间中的所有服务账户：
   ```
   kubectl create rolebinding serviceaccounts-view \
      --clusterrole=view \
      --group=system:serviceaccounts:my-namespace \
      --namespace=my-namespace
   ```
4. 在集群范围内为所有服务账户授予一个受限角色（不鼓励）
   如果你不想管理每一个名字空间的权限，你可以向所有的服务账户授予集群范围的角色。

   例如，为集群范围的所有服务账户授予跨所有名字空间的只读权限：
   ```
   kubectl create clusterrolebinding serviceaccounts-view \
      --clusterrole=view \
      --group=system:serviceaccounts
   ```
5. 授予超级用户访问权限给集群范围内的所有服务帐户（强烈不鼓励）
   如果你不关心如何区分权限，你可以将超级用户访问权限授予所有服务账户。

   > **警告((： 这样做会允许所有应用都对你的集群拥有完全的访问权限，并将允许所有能够读取 Secret（或创建 Pod）的用户对你的集群有完全的访问权限。
   
   ```
   kubectl create clusterrolebinding serviceaccounts-cluster-admin \
      --clusterrole=cluster-admin \
      --group=system:serviceaccounts
   ```
#### 3.1.6 从 ABAC 升级
原来运行较老版本 Kubernetes 的集群通常会使用限制宽松的 ABAC 策略，包括授予所有服务帐户全权访问 API 的能力。

默认的 RBAC 策略为控制面组件、节点和控制器等授予有限的权限，但不会为 `kube-system` 名字空间外的服务账户授权 （除了授予所有认证用户的发现权限之外）。

这样做虽然安全得多，但可能会干扰期望自动获得 API 权限的现有工作负载。这里有两种方法来完成这种转换:
##### 并行鉴权
同时运行 RBAC 和 ABAC 鉴权模式, 并指定包含[现有的 ABAC 策略](https://kubernetes.io/zh/docs/reference/access-authn-authz/abac/#policy-file-format)的策略文件：
```
--authorization-mode=RBAC,ABAC --authorization-policy-file=mypolicy.json
```
关于命令行中的第一个选项：如果早期的鉴权组件，例如 Node，拒绝了某个请求，则 RBAC 鉴权组件尝试对该 API 请求鉴权。如果 RBAC 也拒绝了该 API 请求，则运行 ABAC 鉴权组件。这意味着被 RBAC 或 ABAC 策略所允许的任何请求都是被允许的请求。

如果 API 服务器启动时，`RBAC` 组件的日志级别为 5 或更高（`--vmodule=rbac*=5` 或 `--v=5`），你可以在 API 服务器的日志中看到 `RBAC` 的细节（前缀 `RBAC:`）你可以使用这些信息来确定需要将哪些角色授予哪些用户、组或服务帐户。

一旦你[将角色授予服务账户](https://kubernetes.io/zh/docs/reference/access-authn-authz/rbac/#service-account-permissions)，工作负载运行时在服务器日志中没有出现 RBAC 拒绝消息，就可以删除 ABAC 鉴权器。
#### 3.1.7 宽松的 RBAC 权限
你可以使用 RBAC 角色绑定在多个场合使用宽松的策略。

> **警告**：下面的策略允许所有服务帐户充当集群管理员。容器中运行的所有应用程序都会自动收到服务帐户的凭据，可以对 API 执行任何操作，包括查看 Secrets 和修改权限。这一策略是不被推荐的。
> 
> `kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts`

在你完成到 RBAC 的迁移后，应该调整集群的访问控制，确保相关的策略满足你的信息安全需求。
### 3.2 基于属性的访问控制（Attribute Based Access Control）
### 3.3 节点鉴权（Node Authorization）
### 3.4 Webhook 鉴权（Webhook Authorization）
## 4. 证书签名请求（Certificate Signing Requests）
## 5. 服务账号（Service accounts）

## Reference
- [访问 API](https://kubernetes.io/zh/docs/reference/access-authn-authz/)