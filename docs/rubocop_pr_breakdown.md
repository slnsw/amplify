# RuboCop PR Breakdown Strategy

## Overview

To make RuboCop fixes reviewable and manageable, we'll break them into focused PRs. This approach ensures:

- Each PR is focused on one type of violation
- Changes are easy to review and understand
- Risk is minimized through incremental fixes
- Test failures can be isolated to specific change types

**Original State**: 3,471 total violations across 270 files
**Current State**: ~2,095 violations remaining (1,376 violations fixed)
**Progress**: 39.6% reduction completed

---

## Progress Summary

| PR  | Status         | Violations | Branch                                    | Notes                          |
| --- | -------------- | ---------- | ----------------------------------------- | ------------------------------ |
| #1  | ✅ Complete    | 1,176 → 0  | `chore/rubocop-fix-string-literals`       | String literal standardization |
| #2  | ✅ Complete    | 200 → 0    | `chore/rubocop-fix-hash-braces`           | Hash literal spacing           |
| #3  | 🚧 In Progress | 258        | `chore/rubocop-fix-frozen-string-literal` | Frozen string literals         |
| #4  | ⏳ Planned     | 169        | TBD                                       | Line length violations         |
| #5  | ⏳ Planned     | 39         | TBD                                       | Hash syntax modernization      |

**Total Progress**: 1,376 / 3,471 violations fixed (39.6%)

---

## ✅ **PR #1: Fix Style/StringLiterals (1,176 offenses) - COMPLETED**

**Type:** Safe Auto-correctable
**Status:** ✅ **COMPLETED** - Branch: `chore/rubocop-fix-string-literals`
**Command:** `bundle exec rubocop -a --only Style/StringLiterals`
**Impact:** Standardized single vs double quotes across the codebase
**Risk:** Very low - purely cosmetic change
**Result:** All 1,176 violations fixed across 127 files

### Target Files (in order of priority):

1. `test/models/transcript_edit_test.rb` (~47 offenses)
2. `app/models/transcript.rb` (~31 offenses)
3. `Gemfile` (~29 offenses)
4. `spec/models/transcript_line_spec.rb` (~25 offenses)
5. `spec/models/transcripts_spec.rb` (~20 offenses)

### Review Focus:

- Ensure no accidental string interpolation breakage
- Verify escaped quotes are handled correctly
- Check that heredocs and multi-line strings are preserved

### Commands:

```bash
# Run fix
bundle exec rubocop -a --only Style/StringLiterals

# Verify changes
bundle exec rspec
bundle exec rails test
```

---

## ✅ **PR #2: Fix Layout/SpaceInsideHashLiteralBraces (200 offenses) - COMPLETED**

**Type:** Safe Auto-correctable
**Status:** ✅ **COMPLETED** - Branch: `chore/rubocop-fix-hash-braces`
**Command:** `bundle exec rubocop -a --only Layout/SpaceInsideHashLiteralBraces`
**Impact:** Consistent hash formatting (`{key: value}` vs `{ key: value }`)
**Risk:** Very low - formatting only
**Result:** All 200 violations fixed with consistent hash literal spacing

### Target Approach:

- Fix all files at once (since it's purely formatting)
- Focus review on models and controllers first

### Review Focus:

- Verify hash syntax remains valid
- Check that nested hashes are formatted consistently
- Ensure no syntax errors introduced

### Commands:

```bash
# Run fix
bundle exec rubocop -a --only Layout/SpaceInsideHashLiteralBraces

# Verify changes
bundle exec ruby -c app/models/*.rb
bundle exec rspec
```

---

## 🎯 **PR #3: Fix Style/FrozenStringLiteralComment (258 offenses) - IN PROGRESS**

**Type:** Unsafe Auto-correctable
**Status:** 🚧 **IN PROGRESS** - Branch: `chore/rubocop-fix-frozen-string-literal`
**Command:** `bundle exec rubocop -A --only Style/FrozenStringLiteralComment`
**Impact:** Adds `# frozen_string_literal: true` to file headers
**Risk:** Medium - can affect string mutability behavior

### Batched Approach:

**Batch 1: Models** (~50-60 files)

```bash
bundle exec rubocop -A --only Style/FrozenStringLiteralComment app/models/
```

**Batch 2: Controllers** (~30-40 files)

```bash
bundle exec rubocop -A --only Style/FrozenStringLiteralComment app/controllers/
```

**Batch 3: Tests** (~80-100 files)

```bash
bundle exec rubocop -A --only Style/FrozenStringLiteralComment test/ spec/
```

### Review Focus:

- Check for code that mutates strings: `<<`, `concat`, `gsub!`, `sub!`, `[]='`
- Look for string constants that might be modified
- Verify no performance regressions in critical paths

### High-Risk Files to Review Carefully:

- `app/models/transcript.rb` (complex string operations)
- Files with string manipulation in loops
- Any file using `String.new` or string builders

---

## **PR #4: Fix Layout/LineLength (169 offenses)**

**Type:** Safe Auto-correctable (partial)
**Command:** `bundle exec rubocop -a --only Layout/LineLength`
**Impact:** Breaks long lines to improve readability
**Risk:** Low-Medium - some lines may need manual adjustment

### Target Files (highest impact first):

1. `test/models/transcript_edit_test.rb`
2. `app/models/transcript.rb`
3. Config files (`config/routes.rb`, etc.)
4. Spec files with long expectation chains

### Review Focus:

- Ensure auto-wrapped lines are still readable
- Check that method chaining is preserved correctly
- Verify no semantic changes in complex expressions
- Look for overly aggressive line breaks that hurt readability

### Manual Follow-up:

Some lines may need manual adjustment after auto-correction for optimal readability.

---

## **PR #5: Fix Style/HashSyntax (39 offenses)**

**Type:** Safe Auto-correctable
**Command:** `bundle exec rubocop -a --only Style/HashSyntax`
**Impact:** Modernizes hash syntax (`:key => value` to `key: value`)
**Risk:** Very low - syntax modernization

### Target Areas:

- Older model files
- Configuration files
- Test files (especially older ones)
- Migration files

### Review Focus:

- Verify no hash rockets remain where symbol keys are used
- Check that string keys still use hash rockets appropriately
- Ensure mixed key types are handled correctly

---

## **General PR Guidelines**

### Before Each PR:

1. **Create feature branch**: `git checkout -b chore/rubocop-fix-[cop-name]`
2. **Run the fix command**
3. **Run full test suite**: `bundle exec rspec && bundle exec rails test`
4. **Review all changes manually**
5. **Commit with descriptive message**

### PR Description Template:

```markdown
## RuboCop Fix: [CopName]

### Changes

- Fixed [X] violations of [CopName]
- [Brief description of what was changed]

### Files Changed

- [List of main files or file patterns]

### Testing

- [ ] Full test suite passes
- [ ] No semantic changes verified
- [ ] Manual review completed

### Before/After

- Before: [X] violations
- After: [Y] violations remaining (if any)
```

### Commit Message Format:

```
chore: fix Style/StringLiterals violations

- Standardize to single quotes across codebase
- Auto-corrected 1,176 violations
- No semantic changes, formatting only
```

---

## **Risk Mitigation**

### High-Risk Operations:

1. **Frozen String Literals**: Test string mutation code paths
2. **Line Length**: Verify complex expressions aren't broken
3. **Large Files**: Extra attention to transcript-related files

### Testing Strategy:

- Run full test suite after each PR
- Pay special attention to transcript functionality
- Test in staging environment before merging
- Consider running performance benchmarks for frozen string changes

### Rollback Plan:

- Each PR is independent and can be reverted individually
- Keep `.rubocop_todo.yml` updated to suppress unfixed violations
- Use feature flags for risky changes if needed

---

## **Expected Timeline**

- **PR #1 (StringLiterals)**: 1-2 days
- **PR #2 (HashBraces)**: 1 day
- **PR #3 (FrozenStrings)**: 3-4 days (batched)
- **PR #4 (LineLength)**: 2-3 days
- **PR #5 (HashSyntax)**: 1 day

**Total**: ~2 weeks for top 5 violations, reducing total count by ~85%

After these PRs, remaining violations will be primarily manual review items that can be addressed incrementally in future development cycles.
