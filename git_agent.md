# Git Agent Guidelines

## Branch Naming

Use short, descriptive branch names with one of these prefixes:

- `feat/<feature-name>` for new product or developer-facing functionality.
- `fix/<issue-name>` for bug fixes or behavior corrections.
- `refactor/<area-name>` for internal restructuring without intentional behavior changes.

Keep branch names lowercase and hyphen-separated. Avoid vague names such as `feat/update`,
`fix/bug`, or `refactor/cleanup`.

Examples:

- `feat/profile-screen`
- `fix/video-playback-retry`
- `refactor/auth-repository`

## Pull Request Titles

Write PR titles in English using this format:

```text
feat(feature_name): short imperative summary
fix(issue_name): short imperative summary
refactor(area_name): short imperative summary
```

Guidelines:

- Use the same type as the branch prefix: `feat`, `fix`, or `refactor`.
- Use a concise snake_case scope inside parentheses.
- Write the summary in English.
- Prefer an imperative verb, for example `add`, `fix`, `move`, `split`, or `simplify`.
- Do not end the title with a period.

Examples:

- `feat(profile_screen): add account overview`
- `fix(video_playback): handle retry after stream failure`
- `refactor(auth_repository): split token persistence`
