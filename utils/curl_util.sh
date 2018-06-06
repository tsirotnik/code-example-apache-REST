#------------------------------------------------------
# test example api
#------------------------------------------------------
#    curl -v \
#         -u username:password \
#         -H "Content-Type: application/json" \
#         -X GET \
#         http://localhost/lastResponse
#    curl -X POST \
#         -d '{"username":"TBD", "password": "TBD"}' \
#         https://interview-api.example.com/register
#
#    curl 'https://interview-api.example.com/auth?username=TBD&password=TBD'


#------------------------------------------------------
# test dev service
#------------------------------------------------------

## should be invalid
#curl -v \
#     -u username:password \
#     -d '{"string":"split me"}' \
#     -H "Content-Type: application/json" \
#     -X POST http://localhost/split?signature=xx04e74f3b8cfcf0b502ff701a9b5f0b98ece0d3b4
#
#
## should be invalid
#curl -v \
#     -u username:password \
#     -d '{"odd":["s","l","t","m"], "even":["p","i"," ","e"]}' \
#     -H "Content-Type: application/json" \
#     -X POST http://localhost/join?signature=6edd74450aa9206c4ba0b8c009de382a3e91f404xx
#
#
#
## should be valid
#curl -v \
#     -u TBD:TBD \
#     -d '{"string":"split me"}' \
#     -H "Content-Type: application/json" \
#     -X POST http://localhost/split?signature=04e74f3b8cfcf0b502ff701a9b5f0b98ece0d3b4



## should be valid
#curl -v \
#     -u TBD:TBD \
#     -d '{"odd":["s","l","t","m"], "even":["p","i"," ","e"]}' \
#     -H "Content-Type: application/json" \
#     -X POST http://localhost/join?signature=6edd74450aa9206c4ba0b8c009de382a3e91f404


#curl -v \
#     -u valid1:password1 \
#     http://localhost/lastResponse


#------------------------------------------------------
# test example api
#------------------------------------------------------
#    curl -v \
#         -u username:password \
#         -H "Content-Type: application/json" \
#         -X GET \
#         http://localhost/lastResponse
#    curl -X POST \
#         -d '{"username":"valid1", "password": "password1"}' \
#         https://interview-api.example.com/register
#
#    curl 'https://interview-api.example.com/auth?username=TBD&password=TBD'
