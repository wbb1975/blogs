## 事件总线
传统上，Java的进程内事件分发都是通过发布者和订阅者之间的显式注册实现的。设计EventBus就是为了取代这种显示注册方式，使组件间有了更好的解耦。EventBus不是通用型的发布-订阅实现，不适用于进程间通信。
### 1. 范例
```
// Class is typically registered by the container.
class EventBusChangeRecorder {
  @Subscribe public void recordCustomerChange(ChangeEvent e) {
    recordChange(e.getChange());
  }
}
// somewhere during initialization
eventBus.register(new EventBusChangeRecorder());
// much later
public void changeCustomer()
  ChangeEvent event = getChangeEvent();
  eventBus.post(event);
}
```
### 2. 一分钟指南
### 3. 术语表
### 4. 常见问题解答（FAQ）

## Reference
- [EventBus Explained](https://github.com/google/guava/wiki/EventBusExplained)