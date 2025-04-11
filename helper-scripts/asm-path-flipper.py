#!/usr/bin/env python3
# script execution: python asm-paath-flipper.py utigX+,utigY-,...
import sys

def flip_and_swap(input_string):
    entries = input_string.split(',')
    entries.reverse()

    swapped = []
    for item in entries:
        if item.endswith('+'):
            swapped.append(item[:-1] + '-')
        elif item.endswith('-'):
            swapped.append(item[:-1] + '+')
        else:
            swapped.append(item)

    return ','.join(swapped)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} 'item1+,item2-,item3+'")
        sys.exit(1)

    input_string = sys.argv[1]
    output = flip_and_swap(input_string)
    print()
    print('Reversed path:')
    print()
    print(output)