#!/usr/bin/env python3

L = ["{0:X} & \makecell{{\oki{{{1}}}\\\\\\nim{{1AFD{0:X}}}}} & {2} \\\\".format(e, chr(x[0]), "\makecell{{\oki{{{1}}}\\\\\\nim{{1AFE{0:X}}}}}".format(e, chr(x[1])) if x[1] != 0 else "\cellcolor{black!30}") for e,x in enumerate(zip(range(0xfa80, 0xfa90), list(range(0xfa90, 0xfa9b))+([0x0]*5)))]
print("\n\hline\n& & \\\\\n".join(L[:-5]))
print("\hline\n& & \cellcolor{black!30} \\\\")
print("\n\hline\n& & \cellcolor{black!30} \\\\\n".join(L[-5:]))
print("\hline")
