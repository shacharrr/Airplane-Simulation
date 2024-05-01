package csv

import "core:os"
import "core:fmt"

create :: proc(name: string, columns: []string) -> os.Errno {
    f, err := os.open(name, os.O_CREATE)
    if err != os.ERROR_NONE {
        return err
    }
    defer os.close(f)

    for i := 0; i < len(columns)-1; i += 1 {
        os.write_string(f, columns[i])
        os.write_byte(f, ',')
    }
    os.write_string(f, columns[len(columns)-1])
    os.write_byte(f, '\n')

    return os.ERROR_NONE
}

row :: proc(name: string, values: []f64) -> os.Errno {
    f, err := os.open(name, os.O_APPEND)
    if err != os.ERROR_NONE {
        return err
    }
    defer os.close(f)

    for i := 0; i < len(values)-1; i += 1 {
        os.write_string(f, fmt.aprint(values[i]))
        os.write_byte(f, ',')
    }
    os.write_string(f, fmt.aprint(values[len(values)-1]))
    os.write_byte(f, '\n')

    return os.ERROR_NONE
}