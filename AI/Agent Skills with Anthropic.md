# Agent Skills with Anthropic

## Introduction

Skills give Claude Code and other agents new abilities to carry out tasks. Skills are folders of instructions that extend your agent's capabilities with specialized knowledge. In this course, you'll learn how skills work, learn best practices for creating them, and build skills for different use cases including coding and research and data analysis and more. What's exciting about skills is they're now an open standard, which means they have a standardized format that work with any skills compatible agent. So you can build your skills once and deploy them across multiple agent products.

Any skill should include a SKILL.md markdown file, which contains the skill's name, description, and main instructions. The main instructions can also refer to other files such as scripts, additional markdown files, and assets such as templates and images. skills are progressively disclosed to the agent, which means that the skill's name and description always live in your agent's context window, but the agent does not load the rest of the instructions into its context until a user request matches the skill's description. At that point, the agent might then additionally load the reference and asset files if needed as well.

To use this skill, your agent needs a basic set of tools, filesystem access to read and write files and a bash tool to execute code. And these tools enable your agent to execute whatever command a skill requires. Your agent can combine skills with MCP and sub-agents to create powerful, agentic workflows. For example, it can use MCP to get data from external sources, then rely on a skill to know what to do with that data or how to retrieve it efficiently. It can also delegate tasks to a sub-agent with isolated context, which can itself use skills for specialized knowledge. 

In this course, we'll start with Claude AI, where we'll create a skill for a marketing campaign and combine it with the pre-built skills for Excel and PowerPoint. Then, we'll create two skills for content creation and data analysis workflows and try them with the Claude API. After that, we'll use skills with Claude code for reviewing and testing code. And finally, we'll build a research agent with the Claude agent SDK that uses a skill to combine research results.

So, how do you know when to use a skill? Let's say you have a workflow that you repeatedly ask your agent to implement. Instead of explaining the same workflow every time, you can package it as a skill so your agent automatically knows what to do.

## Course Material

## Reference

- [Agent Skills with Anthropic](https://www.deeplearning.ai/short-courses/agent-skills-with-anthropic/)
- [SKILL.md](http://skill.md/)