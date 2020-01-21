# frozen_string_literal: true

require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"

# If using IAM
authenticator = IBMWatson::Authenticators::IamAuthenticator.new(
  apikey: "2HQBD1cvaMF4TltZ7m-yGLuU-1FSVKaYZWm6HwTtm53C"
)

# If you have username & password in your credentials use:
# authenticator = IBMWatson::Authenticators::BasicAuthenticator.new(
#   username: "{username}",
#   password: "{password}"
# )

# If you have username & password in your credentials use:
service = IBMWatson::AssistantV2.new(
  authenticator: authenticator,
  version: "2018-09-17"
)
service.service_url = "https://api.us-south.assistant.watson.cloud.ibm.com/instances/3170629f-52b3-47fe-a128-e4dc2fd6e993"

#########################
# Sessions
#########################
response = service.create_session(
  assistant_id: "assistant_id"
)

puts JSON.pretty_generate(response.result)

session_id = response.result["session_id"]
service.delete_session(
  assistant_id: "assistant_id",
  session_id: session_id
)

#########################
# Message
#########################
response = service.message(
  assistant_id: "assistant_id",
  session_id: "session_id",
  input: { "text" => "Turn on the lights" },
  context: nil
)
puts JSON.pretty_generate(response.result)