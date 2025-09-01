# RuboCop Detailed Offense Breakdown with Impacted Files

## Overview

This report shows the most common RuboCop violations and which files are affected by each type.

**Total Files Inspected**: 270
**Total Violations**: ~~3,471~~ → **2,295** (Updated)
**Safe Auto-correctable**: ~1,624 (71%)
**Unsafe Auto-correctable**: ~400 (17%)
**Manual Review Required**: ~271 (12%)

**Progress**: 1,176 violations fixed (34% reduction)

---

## ✅ 1. Style/StringLiterals (~~1,176 violations~~ → **0 violations** - COMPLETED!)

**Issue**: Using double quotes instead of single quotes when string interpolation is not needed.

**Status**: ✅ **FIXED** - All 1,176 violations resolved

- **PR**: `chore/rubocop-fix-string-literals`
- **Files Updated**: 127 files with consistent single-quote usage
- **Method**: Safe auto-correction with `bundle exec rubocop -a --only Style/StringLiterals`
- **Testing**: ✅ Database connection verified, Rails loads successfully

**Most Impacted Files (Now Fixed)**:

- ✅ **test/models/transcript_edit_test.rb**: All string literal violations fixed
- ✅ **app/models/transcript.rb**: All string literal violations fixed
- ✅ **spec/models/transcript_line_spec.rb**: All string literal violations fixed
- ✅ **spec/models/transcripts_spec.rb**: All string literal violations fixed
- ✅ **spec/controllers/admin/cms/transcripts_controller_spec.rb**: All violations fixed
- ✅ **Gemfile**: All violations fixed
- ✅ **All spec/test files**: 127 files total updated

---

## 🎯 2. Layout/SpaceInsideHashLiteralBraces (200 violations - 9% of remaining issues)

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

## 🎯 3. Layout/SpaceInsideHashLiteralBraces (200 violations - 9% of remaining issues)

**Issue**: Inconsistent spacing inside hash braces `{key: value}` vs `{ key: value }`.

**Status**: 🎯 **NEXT TARGET**
**Priority**: High - Safe auto-correctable formatting fix

**Most Impacted Files**:

- **test/models/transcript_edit_test.rb**: 130+ violations
- **lib/tasks/sample.rake**: 30+ violations
- **app/models/transcript.rb**: 20+ violations
- **Various other model and task files**: 20+ violations

**Fix**: Safe auto-correctable with `bundle exec rubocop -a --only Layout/SpaceInsideHashLiteralBraces`

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

## ✅ Completion Status

### Completed Fixes:

- ✅ **Style/StringLiterals**: 1,176 violations → 0 violations (**COMPLETE**)
  - PR: `chore/rubocop-fix-string-literals`
  - Impact: 34% reduction in total violations

### Next Priority Fixes:

- 🎯 **Layout/SpaceInsideHashLiteralBraces**: 200 violations (safe auto-correctable)
- 🎯 **Style/FrozenStringLiteralComment**: 258 violations (unsafe auto-correctable)
- 🎯 **Layout/LineLength**: 169 violations (mixed auto-correctable)

## Quick Fix Commands

```bash
# Next recommended fix
bundle exec rubocop -a --only Layout/SpaceInsideHashLiteralBraces

# Individual file targeting
bundle exec rubocop -a app/models/transcript.rb
bundle exec rubocop -a spec/models/

# Fix all safe corrections
bundle exec rubocop --safe-auto-correct
```

## Updated Impact Analysis

**Current State** (after Style/StringLiterals fix):

- **Total violations**: 2,295 (down from 3,471)
- **Reduction achieved**: 1,176 violations (34%)
- **Safe auto-correctable remaining**: ~1,624 violations
- **Manual review required**: ~671 violations
- **Better performance** with frozen string literals
