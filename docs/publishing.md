# Publishing checklist

The initial repository is prepared locally. Publishing requires the owner's approval.

The prepared commit uses a repository-local generic contributor name and `contributors@example.invalid` to avoid publishing the machine's configured personal email. This is a placeholder identity, not a verified GitHub account. Before publishing, the owner may choose their verified GitHub no-reply identity and amend the initial commit. Global Git settings are unchanged.

1. Run both test scripts and inspect `git status --short`.
2. Review `git ls-files`, `git diff --cached`, and `git log --format=fuller`. Commit author emails are public on GitHub; use an appropriate verified GitHub no-reply identity if desired.
3. Confirm every tracked file is source, documentation, the example configuration, or CI. Do not use `git add -f` to override exclusions.
4. Search staged content for real tunnel hosts, local account paths, addresses, tokens, passwords and player identifiers. Examples must remain generic. Ignore rules do not protect secrets pasted into allowed Markdown or scripts.
5. After explicit approval, create an empty GitHub repository named `minecraft-fabric-server` under the intended account, with the chosen visibility. Avoid pre-generating a README because the local project already has one.
6. Add the approved remote URL and push `main`. Check the resulting file list and Windows CI run.

No remote, credentials, public hostname, personal email or player data is included in repository content. Git transport authentication should use the user's normal credential manager, never credentials embedded in a remote URL or script.
