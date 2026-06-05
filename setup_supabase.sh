#!/bin/bash

# VetCare Supabase Schema Setup Script
# This script sets up the complete database schema for the VetCare application
# It assumes you have the Supabase CLI installed and configured

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}VetCare Supabase Setup Script${NC}"
echo "======================================"
echo ""

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}Supabase CLI not found. Please install it first:${NC}"
    echo "npm install -g @supabase/cli"
    exit 1
fi

echo -e "${BLUE}Available projects:${NC}"
supabase projects list

echo ""
echo -e "${BLUE}Enter your Supabase project ID:${NC}"
read PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Project ID is required${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Applying migrations...${NC}"

# Create migrations directory if it doesn't exist
mkdir -p supabase/migrations

# Copy migration files
cp ../migrations/add_document_column.sql supabase/migrations/001_add_document_column.sql

# Apply migrations
supabase migration list --project-ref "$PROJECT_ID"
supabase migration up --project-ref "$PROJECT_ID" || true

echo ""
echo -e "${GREEN}Schema setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Verify the schema in Supabase dashboard"
echo "2. Update RLS policies if needed"
echo "3. Restart the Flutter app"
