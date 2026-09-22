# Universal Local AI Setup (Any Repository, No Cloud-Agent Credits)

This guide is repository-agnostic and works for any project where you want local AI assistance without cloud-agent credit usage.

## 1) Keep Git + GitHub workflow local for any repo

Install:
- Git
- GitHub CLI (`gh`)

Typical workflow (repeat per project):
1. Clone repository: `git clone <repo-url>`
2. Create branch: `git checkout -b <feature-branch>`
3. Commit locally: `git add . && git commit -m "your message"`
4. Push to GitHub: `git push -u origin <feature-branch>`
5. Open PR: `gh pr create`

## 2) Run model locally

Install a local runtime (example: Ollama), then pull a coding model once:

```bash
ollama pull qwen2.5-coder:14b
```

Start/serve locally (default endpoint is usually `http://localhost:11434`).

## 3) Connect your editor to the local model

Use an editor tool that supports local providers (examples: Continue, Cline, Aider, OpenWebUI-based setups) and point it to your local endpoint. Reuse this configuration across repositories:

`http://localhost:<port>`

Replace `<port>` with your runtime port (for Ollama default: `11434`).

## 4) Avoid cloud-agent usage

- Do not run GitHub cloud coding-agent tasks for routine work.
- If using GitHub Copilot in the IDE, stay within free limits or disable cloud-backed features.

## 5) Optional hybrid usage

- Use local models for most routine coding.
- Use paid cloud models only when you need stronger reasoning or larger context.

## 6) Reusable checklist for every new repository

1. Clone repo and create a branch.
2. Confirm local model runtime is running.
3. Open project in your editor with local-AI extension enabled.
4. Verify the extension endpoint is local (`localhost`).
5. Commit and push through normal Git/GitHub workflow.
