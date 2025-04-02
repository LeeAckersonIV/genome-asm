# This script is designed to adjust the verkko assembly.paths.tsv +/- syntax to the patch >/< syntax. E.x. utig4-1479-,utig4-1478- -> <utig4-1479<utig4-1478

# Call the script (asm-path-fixer.py), followed by a string of the +/- path to translate.
## $ asm-path-fixer.py utig4-1479-,utig4-1478-
## > <utig4-1479<utig4-1478

import sys # allows command line args

def convert_verkko_path(path_str): # translates +/- to >/<
    converted = []
    for segment in path_str.split(','):
        if segment.endswith('-'):
            converted.append(f'<{segment[:-1]}')
        elif segment.endswith('+'):
            converted.append(f'>{segment[:-1]}')
        else:
            converted.append(segment)  # catch unexpected format
    return ''.join(converted)

if __name__ == "__main__": # make execution user friendly
    if len(sys.argv) != 2:
        print("Usage: asm-path-fixer.py <verkko_path_string>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = convert_verkko_path(input_path)
    print('\nInput +/- path:\n', input_path)
    print('\nTranslated >/< path:\n',output_path)