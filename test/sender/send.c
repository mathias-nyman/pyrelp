#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "librelp.h"


static relpEngine_t *pRelpEngine;/* our relp engine */
static void dbgprintf(char __attribute__((unused)) *fmt, ...) {
    printf(fmt);
}


int main(int argc, char *argv[]) {

    relpClt_t *pRelpClt;
    unsigned char *target = argv[1];
    unsigned char *port = argv[2];
    unsigned timeout = 90;
    int protFamily = 2; /* IPv4=2, IPv6=10 */

    if(relpEngineConstruct(&pRelpEngine) != RELP_RET_OK) {
        printf("relpEngineConstruct\n");
        return 1;
    }
    if(relpEngineSetDbgprint(pRelpEngine, dbgprintf) != RELP_RET_OK) {
        printf("relpEngineSetDbgprint\n");
        return 1;
    }
    if(relpEngineSetEnableCmd(pRelpEngine, (unsigned char*) "syslog", 3) != RELP_RET_OK) { /* 3=required */
        printf("relpEngineSetEnableCmd\n");
        return 1;
    }
    if(relpEngineCltConstruct(pRelpEngine, &pRelpClt) != RELP_RET_OK) {
        printf("relpEngineCltConstruct\n");
        return 1;
    }
    if(relpCltSetTimeout(pRelpClt, timeout) != RELP_RET_OK) {
        printf("relpCltSetTimeout\n");
        return 1;
    }
    if(relpCltConnect(pRelpClt, protFamily, port, target) != RELP_RET_OK) {
        printf("relpCltConnect\n");
        return 1;
    }


    unsigned char *pMsg = argv[3];
    size_t lenMsg = strlen((char*) pMsg);

    if(relpCltSendSyslog(pRelpClt, pMsg, lenMsg) != RELP_RET_OK) {
        printf("relpCltSendSyslog\n");
        return 1;
    }


    if(relpEngineCltDestruct(pRelpEngine, &pRelpClt) != RELP_RET_OK) {
        printf("relpEngineCltDestruct\n");
        return 1;
    }
    if(relpEngineDestruct(&pRelpEngine) != RELP_RET_OK) {
        printf("relpEngineDestruct\n");
        return 1;
    }
}

