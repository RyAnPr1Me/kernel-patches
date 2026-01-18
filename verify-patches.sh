#!/bin/bash
# Patch Verification Script
# Verifies that patches have been fixed to avoid "file already exists" errors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "================================================================"
echo "Patch Verification Script"
echo "Checking for 'new file mode' issues (January 2026 fix)"
echo "================================================================"
echo ""

# Function to print colored messages
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check for patches with "new file mode"
print_info "Checking all .patch files for problematic 'new file mode' declarations..."
echo ""

PROBLEM_PATCHES=()
TOTAL_PATCHES=0

for patch_file in "${SCRIPT_DIR}"/*.patch; do
    if [ -f "$patch_file" ]; then
        TOTAL_PATCHES=$((TOTAL_PATCHES + 1))
        filename=$(basename "$patch_file")
        
        if grep -q "new file mode" "$patch_file"; then
            PROBLEM_PATCHES+=("$filename")
            print_error "Found issue in: $filename"
        fi
    fi
done

echo ""
echo "================================================================"
echo "VERIFICATION RESULTS"
echo "================================================================"
echo ""

if [ ${#PROBLEM_PATCHES[@]} -eq 0 ]; then
    print_success "All patches are clean!"
    echo ""
    print_info "Checked: $TOTAL_PATCHES patch files"
    print_info "Issues found: 0"
    echo ""
    print_success "Your patches have been fixed and will not cause 'file already exists' errors"
    echo ""
    print_info "These patches can be applied without interactive prompts"
    print_info "Safe for use in automated build systems"
    exit 0
else
    print_error "Found ${#PROBLEM_PATCHES[@]} patch(es) with 'new file mode' issues!"
    echo ""
    print_warning "The following patches need to be updated:"
    for patch in "${PROBLEM_PATCHES[@]}"; do
        echo "  - $patch"
    done
    echo ""
    print_info "Solutions:"
    echo "  1. Download the latest patches from this repository (January 2026 or later)"
    echo "  2. These patches have been fixed to avoid 'file already exists' errors"
    echo ""
    print_warning "Using old patches may cause errors like:"
    echo "  'The next patch would create the file X, which already exists!'"
    exit 1
fi
