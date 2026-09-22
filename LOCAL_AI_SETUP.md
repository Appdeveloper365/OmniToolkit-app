# Local AI Setup (No Cloud-Agent Credits)

This guide shows how to work with GitHub normally while running your coding assistant locally so you can avoid cloud-agent credit usage.

## 1) Keep Git + GitHub workflow local

Install:
- Git
- GitHub CLI (`gh`)

Typical workflow:
1. Clone repository: `git clone <repo-url>`
2. Create branch: `git checkout -b <feature-branch>`
3. Commit locally: `git add . && git commit -m "your message"`
4. Push to GitHub: `git push -u origin <feature-branch>`
5. Open PR: `gh pr create`

## 2) Run model locally

Install a local runtime (example: Ollama), then pull a coding model:

```bash
ollama pull qwen2.5-coder:14b
```

Start/serve locally (default endpoint is usually `http://localhost:11434`).

## 3) Connect your editor to local model

Use an editor tool that supports local providers (examples: Continue, Cline, Aider, OpenWebUI-based setups) and point it to your local endpoint:

`http://localhost:<port>`

Replace `<port>` with your runtime port (for Ollama default: `11434`).

## 4) Avoid cloud-agent usage

- Do not run GitHub cloud coding-agent tasks.
- If using GitHub Copilot in the IDE, stay within free limits or disable cloud-backed features.

## 5) Optional hybrid usage

- Use local models for most routine coding.
- Use paid cloud models only when you need stronger reasoning or larger context.
