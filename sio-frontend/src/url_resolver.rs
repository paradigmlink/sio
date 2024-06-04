use std::collections::HashMap;

#[derive(Debug)]
struct HierarchicalName {
    paths: HashMap<String, String>,
}

impl HierarchicalName {
    fn new() -> Self {
        HierarchicalName {
            paths: HashMap::new(),
        }
    }

    fn add_path(&mut self, key: &str, path: &str) {
        self.paths.insert(key.to_string(), path.to_string());
    }

    fn get_path(&self, key: &str) -> Option<&String> {
        self.paths.get(key)
    }

    fn resolve_composite_key(&self, composite_key: &str) -> Option<String> {
        let keys: Vec<&str> = composite_key.split("::").collect();
        let mut resolved_path = String::new();
        
        for key in keys {
            if let Some(value) = self.get_path(key) {
                if !resolved_path.is_empty() {
                    resolved_path.push_str("::");
                }
                resolved_path.push_str(value);
            } else {
                return None; // Return None if any key is not found
            }
        }
        
        Some(resolved_path)
    }
}

#[derive(Debug)]
struct UrlResolver {
    hierarchical_name: HierarchicalName,
}

impl UrlResolver {
    fn new() -> Self {
        UrlResolver {
            hierarchical_name: HierarchicalName::new(),
        }
    }

    fn resolve_url(&mut self, key: &str, url: &str) {
        // Extract the path from the URL and add it to HierarchicalName
        let path = self.extract_path_from_url(url);
        self.hierarchical_name.add_path(key, &path);
    }

    fn extract_path_from_url(&self, url: &str) -> String {
        // Here you would have your logic to extract the path from the URL
        // For simplicity, this example assumes the URL is just the path
        url.to_string()
    }

    fn get_hierarchical_name(&self) -> &HierarchicalName {
        &self.hierarchical_name
    }

    fn get_path_for_key(&self, key: &str) -> Option<String> {
        if let Some(value) = self.hierarchical_name.get_path(key) {
            if value.contains("::") {
                // The value is a composite key, resolve it
                self.hierarchical_name.resolve_composite_key(value)
            } else {
                Some(value.clone())
            }
        } else {
            None
        }
    }
}

fn main() {
    let mut url_resolver = UrlResolver::new();
    
    // Add URLs with their unique keys
    url_resolver.resolve_url("public_key", "sio79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd");
    url_resolver.resolve_url("type", "src");
    url_resolver.resolve_url("name", "app_name");
    url_resolver.resolve_url("app", "public_key::type::name");
    
    // Query for a specific key to get the path
    if let Some(path) = url_resolver.get_path_for_key("app") {
        println!("Path for 'app': {}", path);
    } else {
        println!("Key 'app' not found!");
    }
    
    // Print all paths for debugging
    println!("{:?}", url_resolver.get_hierarchical_name().paths);
}
