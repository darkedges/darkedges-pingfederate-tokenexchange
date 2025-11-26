/**
 * AWS Lambda: Verify OTP and Exchange Code for Access Token
 * 
 * Purpose: Verify user's OTP and complete OAuth token exchange
 * Validates OTP, retrieves authorization code, and exchanges it for an access token
 * 
 * Expected Input (from AWS Connect):
 * {
 *   "Details": {
 *     "Parameters": {
 *       "flowId": "flow-id-from-initiate-auth",
 *       "userCode": "123456"
 *     }
 *   }
 * }
 * 
 * Environment Variables Required:
 * - PF_BASE_URL: PingFederate base URL (e.g., https://engine.ping.darkedges.com)
 * - CLIENT_ID: OAuth client ID
 * - CLIENT_SECRET: OAuth client secret
 * - REDIRECT_URI: OAuth redirect URI
 */

const {
  PF_BASE_URL,
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URI
} = process.env;

/**
 * Validate required environment variables
 */
function validateEnvironment() {
  const required = ['PF_BASE_URL', 'CLIENT_ID', 'CLIENT_SECRET', 'REDIRECT_URI'];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing environment variables: ${missing.join(', ')}`);
  }
}

/**
 * Extract parameters from AWS Connect event
 * @param {Object} event - AWS Lambda event from Connect
 * @returns {Object} Extracted parameters
 */
function extractParameters(event) {
  const flowId = event?.Details?.Parameters?.flowId;
  const userCode = event?.Details?.Parameters?.userCode;
  
  if (!flowId || !userCode) {
    throw new Error('Missing required parameters: flowId and/or userCode');
  }
  
  return { flowId, userCode };
}

/**
 * Step 1: Submit OTP to verify user
 * POST request with OTP code
 * @param {string} flowId - Flow ID from initiate-auth
 * @param {string} userCode - OTP code from user
 * @returns {Promise<Object>} Response with updated flow status
 */
async function submitOtp(flowId, userCode) {
  const flowUrl = `${PF_BASE_URL}/pf-ws/authn/flows/${flowId}`;

  console.log(`[Step 1] Submitting OTP to flow: ${flowId}`);

  try {
    const response = await fetch(flowUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/vnd.pingidentity.checkOtp+json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        otp: userCode
      })
    });

    if (!response.ok) {
      throw new Error(`OTP endpoint returned ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    console.log(`[Step 1] OTP submitted. New status: ${data.status}`);

    return {
      status: data.status,
      resumeUrl: data.resumeUrl,
      flowId: data.id
    };
  } catch (error) {
    console.error('[Step 1] Error submitting OTP:', error.message);
    throw new Error(`Failed to submit OTP: ${error.message}`);
  }
}

/**
 * Step 2: Extract authorization code from resumeUrl
 * GET request to resumeUrl WITHOUT following redirect
 * CRITICAL: We intercept the Location header to extract the code
 * @param {string} resumeUrl - Resume URL with authorization code
 * @returns {Promise<string>} Authorization code
 */
async function extractAuthorizationCode(resumeUrl) {
  console.log(`[Step 2] Extracting authorization code from resume URL`);

  try {
    const response = await fetch(resumeUrl, {
      method: 'GET',
      redirect: 'manual' // CRITICAL: Do not follow redirects
    });

    // The authorization code is in the Location header redirect
    const locationHeader = response.headers.get('Location');
    
    if (!locationHeader) {
      throw new Error('No Location header found in resume response');
    }

    console.log(`[Step 2] Location header found, parsing code`);

    // Parse the code from the redirect URL
    const codeMatch = locationHeader.match(/[?&]code=([^&]+)/);
    if (!codeMatch || !codeMatch[1]) {
      throw new Error('Authorization code not found in Location header');
    }

    const code = decodeURIComponent(codeMatch[1]);
    console.log(`[Step 2] Authorization code extracted successfully`);

    return code;
  } catch (error) {
    console.error('[Step 2] Error extracting authorization code:', error.message);
    throw new Error(`Failed to extract authorization code: ${error.message}`);
  }
}

/**
 * Step 3: Exchange authorization code for access token
 * POST request to token endpoint with OAuth credentials
 * @param {string} code - Authorization code
 * @returns {Promise<Object>} Token response with access_token
 */
async function exchangeCodeForToken(code) {
  const tokenUrl = `${PF_BASE_URL}/as/token.oauth2`;

  console.log(`[Step 3] Exchanging authorization code for token`);

  try {
    // Build form-urlencoded body
    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI
    });

    const response = await fetch(tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json'
      },
      body: body.toString()
    });

    if (!response.ok) {
      const errorData = await response.text();
      throw new Error(`Token endpoint returned ${response.status}: ${errorData}`);
    }

    const tokenData = await response.json();
    console.log(`[Step 3] Token received successfully`);

    return {
      accessToken: tokenData.access_token,
      tokenType: tokenData.token_type || 'Bearer',
      expiresIn: tokenData.expires_in,
      idToken: tokenData.id_token,
      scope: tokenData.scope
    };
  } catch (error) {
    console.error('[Step 3] Error exchanging code for token:', error.message);
    throw new Error(`Failed to exchange code for token: ${error.message}`);
  }
}

/**
 * Process the verify-token request
 * @param {Object} event - AWS Lambda event
 * @returns {Promise<Object>} Response with access token or error
 */
async function verifyTokenHandler(event) {
  console.log('=== Verify Token Handler ===');
  console.log('Received event:', JSON.stringify(event, null, 2));

  try {
    // Validate environment
    validateEnvironment();

    // Extract parameters from AWS Connect event
    const { flowId, userCode } = extractParameters(event);
    console.log(`[Init] Processing token verification for flow: ${flowId}`);

    // Step 1: Submit OTP
    const otpResponse = await submitOtp(flowId, userCode);
    const { status, resumeUrl } = otpResponse;

    // Check if OTP was valid and we have a resume URL
    if (status !== 'RESUME' || !resumeUrl) {
      console.warn(`[Warn] OTP verification failed. Status: ${status}`);
      return {
        statusCode: 401,
        body: JSON.stringify({
          status: 'FAIL',
          message: 'Invalid OTP or OTP verification failed'
        })
      };
    }

    // Step 2: Extract authorization code from resume URL
    const code = await extractAuthorizationCode(resumeUrl);

    // Step 3: Exchange code for access token
    const tokenResponse = await exchangeCodeForToken(code);

    console.log(`[Success] Token exchange completed successfully`);
    return {
      statusCode: 200,
      body: JSON.stringify({
        status: 'SUCCESS',
        accessToken: tokenResponse.accessToken,
        tokenType: tokenResponse.tokenType,
        expiresIn: tokenResponse.expiresIn,
        idToken: tokenResponse.idToken,
        scope: tokenResponse.scope
      })
    };
  } catch (error) {
    console.error('[Error] Token verification failed:', error.message);
    return {
      statusCode: 500,
      body: JSON.stringify({
        status: 'FAIL',
        message: error.message
      })
    };
  }
}

/**
 * AWS Lambda handler
 */
export const handler = verifyTokenHandler;
