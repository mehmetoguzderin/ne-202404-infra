use lazy_static::lazy_static;
use std::collections::HashMap;

lazy_static! {
    static ref SAKHA_DICT_NOVGORODOV: HashMap<char, &'static str> = [
    ]
    .iter()
    .cloned()
    .collect();
}

fn sakha_cyrillic_to_sakha_latin(text: &str) -> String {
    text.chars()
        .map(|c| {
            SAKHA_DICT_NOVGORODOV
                .get(&c)
                .map(|&s| s.to_string())
                .unwrap_or_else(|| c.to_string())
        })
        .collect()
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(sync)]
pub fn transliterate_sakha_cyrillic_to_sakha_latin(text: String) -> String {
    sakha_cyrillic_to_sakha_latin(&text)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[cfg(feature = "node_bindings")]
mod node_bindings {
    use neon::prelude::*;

    fn hello(mut cx: FunctionContext) -> JsResult<JsString> {
        Ok(cx.string("hello node"))
    }

    fn transliterate_sakha_cyrillic_to_sakha_latin_node(
        mut cx: FunctionContext,
    ) -> JsResult<JsString> {
        let text = cx.argument::<JsString>(0)?.value(&mut cx);
        let result = super::sakha_cyrillic_to_sakha_latin(&text);
        Ok(cx.string(&result))
    }

    #[neon::main]
    fn neon_main(mut cx: ModuleContext) -> NeonResult<()> {
        cx.export_function("hello", hello)?;
        cx.export_function(
            "transliterate_sakha_cyrillic_to_sakha_latin",
            transliterate_sakha_cyrillic_to_sakha_latin_node,
        )?;
        Ok(())
    }
}

#[cfg(feature = "python_bindings")]
mod python_bindings {
    // if not building static library
    use pyo3::prelude::*;

    /// Formats the sum of two numbers as string.
    #[pyfunction]
    fn sum_as_string(a: usize, b: usize) -> PyResult<String> {
        Ok((a + b).to_string())
    }

    #[pyfunction]
    #[pyo3(name = "transliterate_sakha_cyrillic_to_sakha_latin")]
    fn transliterate_sakha_cyrillic_to_sakha_latin_py(text: &str) -> String {
        super::sakha_cyrillic_to_sakha_latin(text)
    }

    /// A Python module implemented in Rust.
    #[pymodule]
    #[pyo3(name = "sigturk_sakha_transliterator")]
    fn python_main(_py: Python, m: &PyModule) -> PyResult<()> {
        m.add_function(wrap_pyfunction!(sum_as_string, m)?)?;
        m.add_function(wrap_pyfunction!(
            transliterate_sakha_cyrillic_to_sakha_latin_py,
            m
        )?)?;
        Ok(())
    }
}
