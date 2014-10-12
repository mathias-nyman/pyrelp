#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "librelp.h"

#define TRY(f) if(f != RELP_RET_OK) { printf("%s\n", #f); return 1; }

static relpEngine_t *pRelpEngine;/* our relp engine */
static void dbgprintf(char __attribute__((unused)) *fmt, ...) {
    printf(fmt);
}
static relpRetVal onSyslogRcv(unsigned char *pHostname, unsigned char *pIP, unsigned char *msg, size_t lenMsg) {
    FILE *f = fopen("test/receiver/logs/rsyslog.log", "w");
    fprintf(f, "%s\n", msg);
    fflush(f);

    return RELP_RET_OK;
}

int main(int argc, char *argv[]) {

    relpSrv_t *pRelpSrv;
    unsigned char *port = argv[1];
    int protFamily = 2; /* IPv4=2, IPv6=10 */

    TRY(relpEngineConstruct(&pRelpEngine));
    TRY(relpEngineSetDbgprint(pRelpEngine, dbgprintf));
    TRY(relpEngineSetEnableCmd(pRelpEngine, (unsigned char*) "syslog", 3)); /* 3=required */
    TRY(relpEngineSetFamily(pRelpEngine, protFamily));
    TRY(relpEngineSetSyslogRcv(pRelpEngine, onSyslogRcv));
    TRY(relpEngineSetDnsLookupMode(pRelpEngine, 0)); /* 0=disable */

    TRY(relpEngineListnerConstruct(pRelpEngine, &pRelpSrv));
    TRY(relpSrvSetLstnPort(pRelpSrv, port));
    TRY(relpEngineListnerConstructFinalize(pRelpEngine, pRelpSrv));

    TRY(relpEngineRun(pRelpEngine)); /* Abort with ctrl-c */

    TRY(relpEngineSetStop(pRelpEngine));
    TRY(relpEngineDestruct(&pRelpEngine));
}

