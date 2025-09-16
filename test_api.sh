#!/bin/bash

# Test script for SkillBallr API endpoints
echo "🧪 Testing SkillBallr API Endpoints"
echo "=================================="

# Test 1: Send verification code
echo "📧 Step 1: Sending verification code..."
VERIFICATION_RESPONSE=$(curl -s -X POST https://skillballr.com/api/auth/send-verification \
  -H "Content-Type: application/json" \
  -d '{"email": "testuser@skillballr.com"}')

echo "Response: $VERIFICATION_RESPONSE"

# Test 2: Try signup with dummy code (should fail)
echo ""
echo "🔐 Step 2: Testing signup with invalid code..."
SIGNUP_RESPONSE=$(curl -s -X POST https://skillballr.com/api/auth/email-signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@skillballr.com",
    "code": "123456",
    "role": "player",
    "position": "QB",
    "firstName": "Test",
    "lastName": "User"
  }')

echo "Response: $SIGNUP_RESPONSE"

# Test 3: Try with different role format
echo ""
echo "🔐 Step 3: Testing with capitalized role..."
SIGNUP_RESPONSE2=$(curl -s -X POST https://skillballr.com/api/auth/email-signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser2@skillballr.com",
    "code": "123456",
    "role": "Player",
    "position": "QB",
    "firstName": "Test",
    "lastName": "User2"
  }')

echo "Response: $SIGNUP_RESPONSE2"

# Test 4: Try coach role
echo ""
echo "🔐 Step 4: Testing coach role..."
COACH_RESPONSE=$(curl -s -X POST https://skillballr.com/api/auth/email-signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testcoach@skillballr.com",
    "code": "123456",
    "role": "coach",
    "position": null,
    "firstName": "Test",
    "lastName": "Coach"
  }')

echo "Response: $COACH_RESPONSE"

echo ""
echo "✅ API testing complete!"
