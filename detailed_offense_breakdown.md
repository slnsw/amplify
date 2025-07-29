# RuboCop Detailed Offense Breakdown with Impacted Files

## Overview

This report shows the most common RuboCop violations and which files are affected by each type.

**Total Files Inspected**: 270
**Total Violations**: 3,897
**Auto-correctable**: 3,310 (85%)

---

## 1. Style/StringLiterals (1,360 violations - 35% of all issues)

**Issue**: Using double quotes instead of single quotes when string interpolation is not needed.

**Most Impacted Files**:

- **Gemfile**: 175 violations
- **app/models/transcript.rb**: 115 violations
- **spec/models/transcript_line_spec.rb**: 88 violations
- **test/models/transcript_edit_test.rb**: 85 violations
- **spec/models/transcripts_spec.rb**: 72 violations
- **spec/controllers/admin/cms/transcripts_controller_spec.rb**: 59 violations
- **spec/models/collections_spec.rb**: 40 violations
- **spec/controllers/admin/cms/collections_controller_spec.rb**: 38 violations
- **spec/controllers/admin/pages_controller_spec.rb**: 36 violations
- **app/helpers/admin_helper.rb**: 31 violations

**Fix**: Auto-correctable with `bundle exec rubocop -a`

---

## 2. Style/FrozenStringLiteralComment (260 violations - 7% of all issues)

**Issue**: Missing `# frozen_string_literal: true` magic comment at the top of files.

**Impact**: Nearly all Ruby files (260 out of 270) are missing this performance optimization.

**File Types Affected**:

- Controllers (app/controllers/\*)
- Models (app/models/\*)
- Helpers (app/helpers/\*)
- Specs (spec/\*\*)
- Tests (test/\*\*)
- Rake tasks (lib/tasks/\*)
- Configuration files

**Fix**: Auto-correctable with `bundle exec rubocop -a`

---

## 3. Layout/SpaceInsideHashLiteralBraces (224 violations - 6% of all issues)

**Issue**: Inconsistent spacing inside hash braces `{key: value}` vs `{ key: value }`.

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: 130 violations
- **lib/tasks/sample.rake**: 40 violations
- **app/models/transcript.rb**: 24 violations
- **lib/tasks/transcripts.rake**: 10 violations
- **app/models/transcript_line.rb**: 4 violations
- **app/models/collection.rb**: 4 violations
- **app/controllers/transcripts_controller.rb**: 4 violations

**Fix**: Auto-correctable with `bundle exec rubocop -a`

---

## 4. Layout/LineLength (150 violations - 4% of all issues)

**Issue**: Lines exceeding 120 characters (configured limit).

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: 65 violations
- **app/models/transcript.rb**: 21 violations
- **lib/tasks/sample.rake**: 18 violations
- **spec/models/transcript_line_spec.rb**: 6 violations
- **spec/services/stats_service_spec.rb**: 5 violations
- **app/models/transcript_search.rb**: 4 violations
- **spec/services/voice_base/import_srt_transcripts_spec.rb**: 3 violations

**Fix**: Mix of auto-correctable and manual review needed

---

## 5. Style/HashSyntax (63 violations - 2% of all issues)

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
