*** Settings ***
Library  OperatingSystem 
Library  String
Suite Setup  Start receiver
Suite Teardown  Stop receiver

*** Variables ***
${g_magic_message} =  kjqowiejflksjdlkf
${g_relp_port} =  20514
${g_receiver_log_dir} =  ${CURDIR}${/}receiver/logs
${g_receiver_log} =  ${g_receiver_log_dir}${/}rsyslog.log


*** Keywords ***

Start receiver
    Remove File  ${g_receiver_log}
    Create File  ${g_receiver_log}
    ${g_docker_id} =  Run  docker run -d -P -v ${g_receiver_log_dir}:/rsyslog -t rsyslog-receiver
    Set Suite Variable  ${g_docker_id}

Get receiver IP
    ${g_receiver_ip} =  Run  docker inspect ${g_docker_id} | grep IPAddress | /bin/grep -Po "\\d+\\.\\d+\\.\\d+.\\d+"
    Set Test Variable  ${g_receiver_ip}

Stop receiver
    Run  docker stop ${g_docker_id}
    Run  docker rm ${g_docker_id}

An rsyslog receiver is running
    Get receiver IP

The reference C sender sends a message
    ${g_magic_message} =  Generate Random String
    Set Test Variable  ${g_magic_message}
    Run  cd .. && ./test/sender/send ${g_receiver_ip} ${g_relp_port} ${g_magic_message}

The rsyslog receiver receives the message 
    ${rc} =  Run And Return Rc  grep ${g_magic_message} ${g_receiver_log}
    Should Be Equal As Integers  ${rc}  0

The pyrelp client sends a message
    ${g_magic_message} =  Generate Random String
    Set Test Variable  ${g_magic_message}
    Run  cd .. && LD_LIBRARY_PATH=librelp/src/.libs PYTHONPATH=src ./bin/pyrelp ${g_receiver_ip} ${g_relp_port} ${g_magic_message}


*** Test Cases ***
Verify the reference C sender
    Given an rsyslog receiver is running
    When the reference C sender sends a message
    Then the rsyslog receiver receives the message 

Verify that the pyrelp client
    Given an rsyslog receiver is running
    When the pyrelp client sends a message
    Then the rsyslog receiver receives the message 
    
