---
title: "`gh stack rebase --no-trunk`: Reviewer-friendly rebasing for stacked PRs"
date: 2026-09-16
description: "Use gh stack rebase --no-trunk to rebase stacked PRs without pulling in dev, making it much easier for reviewers to see just your changes."
draft: false
toc: false
codeMaxLines: 100
categories:
  - Coding
  - Git
tags:
  - GitHub
  - Git
  - Stacked PRs
  - gh
---

> TL;DR: `gh stack rebase --no-trunk` is a reviewer friendly way to rebase your stacked PRs. Just as the blog title suggests.

Regarding GitHub stacked PRs: If you've already got someone reviewing a PR and they've requested changes, the temptation is to just do `gh stack rebase` to get all your stacks updated again. Out of the box this has the side-effect of pulling an updated dev and rebasing the first branch on it.

That leaves the reviewer with a completely new set of commits and there's no way to view just the changes since the last one.

To work around this, you can use `gh stack rebase --no-trunk` - this rebases **just your branches** on top of one another - you don't pull in dev and the reviewer has an easier time reviewing the PR. Be kind to reviewers!