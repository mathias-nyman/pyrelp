#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "librelp.h"

#define TRY(f) if(f != RELP_RET_OK) { printf("%s\n", #f); return 1; }

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

    TRY(relpEngineConstruct(&pRelpEngine));
    TRY(relpEngineSetDbgprint(pRelpEngine, dbgprintf));
    TRY(relpEngineSetEnableCmd(pRelpEngine, (unsigned char*) "syslog", 3)); /* 3=required */
    TRY(relpEngineCltConstruct(pRelpEngine, &pRelpClt));
    TRY(relpCltSetTimeout(pRelpClt, timeout));
    TRY(relpCltConnect(pRelpClt, protFamily, port, target));

    unsigned char *pMsg = argv[3];
    size_t lenMsg = strlen((char*) pMsg);
    TRY(relpCltSendSyslog(pRelpClt, pMsg, lenMsg));

    TRY(relpEngineCltDestruct(pRelpEngine, &pRelpClt));
    TRY(relpEngineDestruct(&pRelpEngine));
}

