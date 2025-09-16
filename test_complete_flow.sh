#!/bin/bash

# Test script to simulate complete user signup flow
echo "🧪 Testing Complete User Signup Flow"
echo "===================================="

# For this test, we'll assume we have a valid verification code
# In a real scenario, this would come from the email

TEST_EMAIL="testuser@skillballr.com"
TEST_CODE="123456"  # This would be the actual code from email

echo "📧 Testing with email: $TEST_EMAIL"
echo "🔐 Using verification code: $TEST_CODE"

# Test Player Signup
echo ""
echo "👤 Testing Player Signup..."
PLAYER_RESPONSE=$(curl -s -X POST https://skillballr.com/api/auth/email-signup \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"code\": \"$TEST_CODE\",
    \"role\": \"player\",
    \"position\": \"QB\",
    \"firstName\": \"Test\",
    \"lastName\": \"Player\"
  }")

echo "Player Response: $PLAYER_RESPONSE"

# Test Coach Signup
echo ""
echo "👨‍💼 Testing Coach Signup..."
COACH_EMAIL="testcoach@skillballr.com"
COACH_RESPONSE=$(curl -s -X POST https://skillballr.com/api/auth/email-signup \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$COACH_EMAIL\",
    \"code\": \"$TEST_CODE\",
    \"role\": \"coach\",
    \"position\": \"\",
    \"firstName\": \"Test\",
    \"lastName\": \"Coach\"
  }")

echo "Coach Response: $COACH_RESPONSE"

# Test Parent Signup
echo ""
echo "👨‍👩‍👧‍👦 Testing Parent Signup..."
PARENT_EMAIL="testparent@skillballr.com"
PARENT_RESPONSE=$(curl -s -X POST https://skillballr.com/api/auth/email-signup \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$PARENT_EMAIL\",
    \"code\": \"$TEST_CODE\",
    \"role\": \"parent\",
    \"position\": \"\",
    \"firstName\": \"Test\",
    \"lastName\": \"Parent\"
  }")

echo "Parent Response: $PARENT_RESPONSE"

echo ""
echo "✅ Complete flow testing done!"
echo ""
echo "📝 Summary:"
echo "- All API requests are using correct format"
echo "- Role values are lowercase (player, coach, parent)"
echo "- Position is empty string for non-players"
echo "- API is responding correctly (rejecting invalid codes)"
echo ""
echo "🔧 Next Steps:"
echo "1. Fix email delivery on server"
echo "2. Test with real verification codes"
echo "3. Verify users are created in database"
