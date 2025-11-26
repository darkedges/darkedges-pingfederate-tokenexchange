/**
 * AWS Lambda: Initiate OAuth Flow and Trigger OTP via SMS
 * 
 * Purpose: Start the headless authentication flow with PingFederate
 * Initiates OAuth authorization flow and sends OTP to user's phone number
 * 
 * Expected Input (from AWS Connect):
 * {
 *   "Details": {
 *     "Parameters": {
 *       "phoneNumber": "+1234567890"
 *     }
 *   }
 * }
 * 
 * Environment Variables Required:
 * - PF_BASE_URL: PingFederate base URL (e.g., https://engine.ping.darkedges.com)
 * - CLIENT_ID: OAuth client ID
 * - REDIRECT_URI: OAuth redirect URI
 * - CLIENT_SECRET: OAuth client secret (for validation, if needed)
 */

const {
  PF_BASE_URL,
  CLIENT_ID,
  REDIRECT_URI,
  CLIENT_SECRET
} = process.env;

/**
 * Validate required environment variables
 */
function validateEnvironment() {
  const required = ['PF_BASE_URL', 'CLIENT_ID', 'REDIRECT_URI', 'CLIENT_SECRET'];
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
  const phoneNumber = event?.Details?.Parameters?.phoneNumber;
  
  if (!phoneNumber) {
    throw new Error('Missing required parameter: phoneNumber');
  }
  
  return { phoneNumber };
}

/**
 * Step 1: Initiate OAuth authorization flow
 * GET request to PingFederate authorization endpoint
 * @param {string} phoneNumber - User's phone number for context
 * @returns {Promise<Object>} Response with flowId and status
 */
async function initiateAuthorizationFlow(phoneNumber) {
  const params = new URLSearchParams({
    client_id: CLIENT_ID,
    response_type: 'code',
    scope: 'openid',
    redirect_uri: REDIRECT_URI,
    'pi.flow': 'true'
  });

  const authUrl = `${PF_BASE_URL}/as/authorization.oauth2?${params.toString()}`;

  console.log(`[Step 1] Initiating OAuth flow at: ${PF_BASE_URL}/as/authorization.oauth2`);

  try {
    const response = await fetch(authUrl, {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`Authorization endpoint returned ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    console.log(`[Step 1] Authorization flow initiated. Status: ${data.status}`);

    return {
      flowId: data.id,
      status: data.status,
      resumeUrl: data.resumeUrl
    };
  } catch (error) {
    console.error('[Step 1] Error initiating authorization flow:', error.message);
    throw new Error(`Failed to initiate authorization flow: ${error.message}`);
  }
}

/**
 * Step 2: Submit phone number to identify user
 * POST request with phone number identifier
 * @param {string} flowId - Flow ID from previous step
 * @param {string} phoneNumber - User's phone number
 * @returns {Promise<Object>} Response with updated status
 */
async function submitIdentifier(flowId, phoneNumber) {
  const flowUrl = `${PF_BASE_URL}/pf-ws/authn/flows/${flowId}`;

  console.log(`[Step 2] Submitting identifier to flow: ${flowId}`);

  try {
    const response = await fetch(flowUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/vnd.pingidentity.checkIdentifier+json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        identifier: phoneNumber
      })
    });

    if (!response.ok) {
      throw new Error(`Flow endpoint returned ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    console.log(`[Step 2] Identifier submitted. New status: ${data.status}`);

    return {
      flowId: data.id,
      status: data.status,
      resumeUrl: data.resumeUrl
    };
  } catch (error) {
    console.error('[Step 2] Error submitting identifier:', error.message);
    throw new Error(`Failed to submit identifier: ${error.message}`);
  }
}

/**
 * Process the initiate-auth request
 * @param {Object} event - AWS Lambda event
 * @returns {Promise<Object>} Response with flowId or error
 */
async function initiateAuthHandler(event) {
  console.log('=== Initiate Auth Handler ===');
  console.log('Received event:', JSON.stringify(event, null, 2));

  try {
    // Validate environment
    validateEnvironment();

    // Extract parameters from AWS Connect event
    const { phoneNumber } = extractParameters(event);
    console.log(`[Init] Processing auth initiation for phone: ${phoneNumber}`);

    // Step 1: Initiate OAuth flow
    const flowResponse = await initiateAuthorizationFlow(phoneNumber);
    const { flowId, status } = flowResponse;

    // Step 2: Submit phone number identifier
    if (status === 'IDENTIFIER_REQUIRED') {
      const identifierResponse = await submitIdentifier(flowId, phoneNumber);
      const updatedStatus = identifierResponse.status;

      // Check if OTP was sent successfully
      if (updatedStatus === 'OTP_REQUIRED') {
        console.log(`[Success] OTP has been sent to ${phoneNumber}`);
        return {
          statusCode: 200,
          body: JSON.stringify({
            status: 'OTP_SENT',
            flowId: flowId,
            message: `OTP sent to ${phoneNumber}`
          })
        };
      } else {
        console.warn(`[Warn] Unexpected status after identifier submission: ${updatedStatus}`);
        return {
          statusCode: 400,
          body: JSON.stringify({
            status: 'FAIL',
            message: `Unexpected flow status: ${updatedStatus}`
          })
        };
      }
    } else {
      console.warn(`[Warn] Expected IDENTIFIER_REQUIRED, got: ${status}`);
      return {
        statusCode: 400,
        body: JSON.stringify({
          status: 'FAIL',
          message: `Unexpected initial status: ${status}`
        })
      };
    }
  } catch (error) {
    console.error('[Error] Auth initiation failed:', error.message);
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
export const handler = initiateAuthHandler;
