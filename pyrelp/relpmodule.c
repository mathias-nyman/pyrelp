/* Python 2.x extension
 *
 * This files sole purpose is to create a shared object containing the librelp
 * functions.
 *
 * */

#include <Python.h>
#include "librelp.h"

static PyMethodDef relp_methods[] =
{
    {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC
initrelp(void)
{
    (void) Py_InitModule("relp", relp_methods);
}

