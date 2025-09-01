# RuboCop Detailed Offense Breakdown with Impacted Files

## Overview

This report shows the most common RuboCop violations and which files are affected by each type.

**Total Files Inspected**: 270
**Total Violations**: 3,471
**Safe Auto-correctable**: ~2,800 (81%)
**Unsafe Auto-correctable**: ~400 (12%)
**Manual Review Required**: ~271 (7%)

---

## 1. Style/StringLiterals (1,176 violations - 34% of all issues)

**Issue**: Using double quotes instead of single quotes when string interpolation is not needed.

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: 280+ violations (most critical file)
- **app/models/transcript.rb**: 115+ violations
- **spec/models/transcript_line_spec.rb**: 88+ violations
- **spec/models/transcripts_spec.rb**: 72+ violations
- **spec/controllers/admin/cms/transcripts_controller_spec.rb**: 59+ violations
- **Gemfile**: 50+ violations
- **Various spec files**: 200+ violations across test files

**Fix**: Safe auto-correctable with `bundle exec rubocop -a`

---

## 2. Style/FrozenStringLiteralComment (258 violations - 7% of all issues)

**Issue**: Missing `# frozen_string_literal: true` magic comment at the top of files.

**Impact**: Nearly all Ruby files (258 out of 270) are missing this performance optimization.

**File Types Affected**:

- Controllers (app/controllers/\*)
- Models (app/models/\*)
- Helpers (app/helpers/\*)
- Specs (spec/\*\*)
- Tests (test/\*\*)
- Rake tasks (lib/tasks/\*)
- Configuration files

**Fix**: Unsafe auto-correctable with `bundle exec rubocop -A` (requires careful review)

---

## 3. Layout/SpaceInsideHashLiteralBraces (200 violations - 6% of all issues)

**Issue**: Inconsistent spacing inside hash braces `{key: value}` vs `{ key: value }`.

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: 130+ violations
- **lib/tasks/sample.rake**: 30+ violations
- **app/models/transcript.rb**: 20+ violations
- **Various other model and task files**: 20+ violations

**Fix**: Safe auto-correctable with `bundle exec rubocop -a`

---

## 4. Layout/LineLength (169 violations - 5% of all issues)

**Issue**: Lines exceeding 120 characters (configured limit).

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: 65+ violations
- **app/models/transcript.rb**: 20+ violations
- **lib/tasks/sample.rake**: 15+ violations
- **Various spec files**: 50+ violations total

**Fix**: Mix of safe auto-correctable and manual review needed

---

## 5. Naming/MethodName (61 violations - 2% of all issues)

**Issue**: Method names not following snake_case convention.

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: Major contributor with methods like `seedProject`, `seedTranscript`
- Various model and helper files

**Fix**: Manual review required - cannot be auto-corrected

---

## 6. RSpec and Layout Issues (Combined ~400 violations)

**Key Issues**:

- **Layout/EmptyLinesAroundBlockBody**: 48 violations (Safe Correctable)
- **RSpec/LetSetup**: 48 violations (Manual review)
- **RSpec/MultipleExpectations**: 47 violations (Manual review)
- **Layout/DotPosition**: 46 violations (Safe Correctable)
- **RSpec/MultipleMemoizedHelpers**: 43 violations (Manual review)

---

## 7. Style/HashSyntax (39 violations - 1% of all issues)

**Issue**: Using old hash syntax `:key => value` instead of `key: value`.

**Most Impacted Files**:

- **app/models/**: Legacy model files
- **spec/**: Older spec files
- **lib/**: Task and utility files

**Fix**: Auto-correctable with `bundle exec rubocop -a`

---

## File Priority Recommendations

### 🔥 High Priority (Most violations)

1. **Gemfile** (175+ violations) - Start here for quick wins
2. **app/models/transcript.rb** (160+ violations total) - Core model
3. **test/models/transcript_edit_test.rb** (280+ violations total) - Highest single file
4. **spec/models/transcript_line_spec.rb** (94+ violations total) - Main spec file

### 🎯 Medium Priority (Significant impact)

5. **spec/models/transcripts_spec.rb** (72+ violations)
6. **lib/tasks/sample.rake** (58+ violations)
7. **app/helpers/admin_helper.rb** (31+ violations)

### 📋 Systematic Cleanup

7. **All remaining files**: Add frozen string literals across all 260 files

---

## Quick Fix Commands

```bash
# Fix specific file types
bundle exec rubocop -a Gemfile
bundle exec rubocop -a app/models/transcript.rb
bundle exec rubocop -a spec/models/

# Fix all auto-correctable issues
bundle exec rubocop -a

# Fix only safe corrections (more conservative)
bundle exec rubocop --safe-auto-correct
```

## Expected Impact

After running auto-corrections:

- **~3,310 violations fixed automatically** (85%)
- **~587 violations remaining** for manual review
- **Significant improvement** in code consistency
- **Better performance** with frozen string literals
