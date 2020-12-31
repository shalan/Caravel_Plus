#!/bin/env python3
# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

#
# compositor.py ---
#
#    Compose the final GDS for caravel from the caravel GDS, seal ring
#    GDS, and fill GDS.
#

import sys
import os
import re
import subprocess

def usage():
    print("Usage:")
    print("compositor.py [<path_to_project>] [-keep]")
    print("")
    print("where:")
    print("   <path_to_project> is the path to the project top level directory.")
    print("")
    print("  If <path_to_project> is not given, then it is assumed to be the cwd.")
    print("  If '-keep' is specified, then keep the generation script.")
    return 0

if __name__ == '__main__':

    optionlist = []
    arguments = []

    debugmode = False
    keepmode = False

    for option in sys.argv[1:]:
        if option.find('-', 0) == 0:
            optionlist.append(option)
        else:
            arguments.append(option)

    if len(arguments) > 1:
        print("Wrong number of arguments given to compositor.py.")
        usage()
        sys.exit(0)

    if len(arguments) == 1:
        user_project_path = arguments[0]
    else:
        user_project_path = os.getcwd()

    # Check for valid user path

    if not os.path.isdir(user_project_path):
        print('Error:  Project path "' + user_project_path + '" does not exist or is not readable.')
        sys.exit(1)

    # Check for valid user ID
    user_id_value = None
    if os.path.isfile(user_project_path + '/info.yaml'):
        with open(user_project_path + '/info.yaml', 'r') as ifile:
            infolines = ifile.read().splitlines()
            for line in infolines:
                kvpair = line.split(':')
                if len(kvpair) == 2:
                    key = kvpair[0].strip()
                    value = kvpair[1].strip()
                    if key == 'project_id':
                        user_id_value = value.strip('"\'')
                        break

    if user_id_value:
        project = 'caravel'
        project_with_id = 'caravel_' + user_id_value
    else:
        print('Error:  No project_id found in info.yaml file.')
        sys.exit(1)

    if '-debug' in optionlist:
        debugmode = True
    if '-keep' in optionlist:
        keepmode = True

    magpath = user_project_path + '/mag'
    rcfile = magpath + '/.magicrc'

    with open(magpath + '/compose_final.tcl', 'w') as ofile:
        print('#!/bin/env wish', file=ofile)
        print('drc off', file=ofile)

        print('load ' + project + ' -dereference', file=ofile)
        print('select top cell', file=ofile)

        # Ceate a cell to represent the generated fill.  There are
        # no magic layers corresponding to the fill shape data, and
        # it's gigabytes anyway, so we don't want to deal with any
        # actual data.  So it's just a placeholder.

        print('set bbox [box values]', file=ofile)
        print('load ' + project_with_id + '_fill_pattern', file=ofile)
        print('snap internal', file=ofile)
        print('box values {*}$bbox', file=ofile)
        print('paint comment', file=ofile)
        print('property GDS_FILE ../gds/' + project_with_id + '_fill_pattern.gds', file=ofile)
        print('property GDS_START 0', file=ofile)
        print('property FIXED_BBOX "$bbox"', file=ofile)

        # Now go back to the project top level and place the fill cell.
        print('load ' + project, file=ofile)
        print('select top cell', file=ofile)	
        print('getcell ' + project_with_id + '_fill_pattern child 0 0', file=ofile)

        # Move existing origin to (6um, 6um) for seal ring placement
        print('move origin -6um -6um', file=ofile)

        # Read in abstract view of seal ring
        print('box position 0 0', file=ofile)
        print('getcell advSeal_6um_gen', file=ofile)

        # Write out completed project as "caravel_" + the user ID
        print('save ' + project_with_id, file=ofile)

        # Generate final GDS
        print('puts stdout "Writing final GDS. . . "', file=ofile)
        print('flush stdout', file=ofile)
        print('gds write ../gds/' + project_with_id + '.gds', file=ofile)
        print('quit -noprompt', file=ofile)

    myenv = os.environ.copy()
    # Abstract views are appropriate for final composition
    myenv['MAGTYPE'] = 'maglef'

    print('Building final GDS file ' + project_with_id + '.gds', flush=True)

    mproc = subprocess.run(['magic', '-dnull', '-noconsole',
		'-rcfile', rcfile, magpath + '/compose_final.tcl'],
		stdin = subprocess.DEVNULL,
		stdout = subprocess.PIPE,
		stderr = subprocess.PIPE,
		cwd = magpath,
		env = myenv,
		universal_newlines = True)
    if mproc.stdout:
        for line in mproc.stdout.splitlines():
            print(line)
    if mproc.stderr:
        # NOTE:  Until there is a "load -quiet" option in magic, loading
        # a new cell generates an error.  This code ignores the error.
        newlines = []
        for line in mproc.stderr.splitlines():
            if line.endswith("_fill_pattern.mag couldn't be read"):
                continue
            if line.startswith("No such file or directory"):
                continue
            else:
                newlines.append(line)

        if len(newlines) > 0:
            print('Error message output from magic:')
            for line in newlines:
                print(line)
        if mproc.returncode != 0:
            print('ERROR:  Magic exited with status ' + str(mproc.returncode))

    if not keepmode:
        os.remove(magpath + '/compose_final.tcl')

    print('Done!')
    exit(0)
