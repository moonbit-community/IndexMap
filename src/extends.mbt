///|
pub extend T with @moonbitlang/core/quickcheck.Arbitrary::{arbitrary}

///|
pub extend T with Show::{to_string, output}

///|
pub extend T with ToJson::{to_json}
