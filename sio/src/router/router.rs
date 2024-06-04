extern crate alloc;

use alloc::string::String;
use crate::alloc::string::ToString;
use alloc::vec::Vec;
use hashbrown::HashMap;
use rand::Rng;
use rand::rngs::SmallRng;
use rand::SeedableRng;

#[derive(Debug)]
struct Link {
    history: HashMap<String, Vec<f64>>, // History per public key
    cdfs: HashMap<String, Vec<(f64, f64)>>, // CDF per public key
}

impl Link {
    fn new() -> Self {
        Link {
            history: HashMap::new(),
            cdfs: HashMap::new(),
        }
    }

    fn update_history(&mut self, public_key: &str, response_time: f64) {
        self.history.entry(public_key.to_string()).or_insert(Vec::new()).push(response_time);
        self.update_cdf(public_key);
    }

    fn update_cdf(&mut self, public_key: &str) {
        if let Some(history) = self.history.get(public_key) {
            let mut sorted_history = history.clone();
            sorted_history.sort_by(|a, b| a.partial_cmp(b).unwrap());

            let total = sorted_history.len() as f64;
            let mut cdf = Vec::new();
            for (i, &delay) in sorted_history.iter().enumerate() {
                cdf.push((delay, (i + 1) as f64 / total));
            }
            self.cdfs.insert(public_key.to_string(), cdf);
        }
    }
}

fn sample_cdf(cdf: &[(f64, f64)]) -> f64 {
    let mut rng = SmallRng::seed_from_u64(0); // Use a seed for determinism
    let p: f64 = rng.gen();

    for &(delay, prob) in cdf {
        if p <= prob {
            return delay;
        }
    }

    cdf.last().unwrap().0
}

fn estimate_expected_delay(cdf: &[(f64, f64)], num_samples: usize) -> f64 {
    let mut total_delay = 0.0;
    for _ in 0..num_samples {
        total_delay += sample_cdf(cdf);
    }
    total_delay / num_samples as f64
}

fn select_best_link(links: &HashMap<u32, Link>, public_key: &str, num_samples: usize) -> Option<u32> {
    let mut best_link = None;
    let mut best_delay = f64::MAX;

    for (&link_id, link) in links.iter() {
        if let Some(cdf) = link.cdfs.get(public_key) {
            let expected_delay = estimate_expected_delay(cdf, num_samples);
            if expected_delay < best_delay {
                best_delay = expected_delay;
                best_link = Some(link_id);
            }
        }
    }

    best_link
}

fn main() {
    let mut links: HashMap<u32, Link> = HashMap::new();

    // Initialize links with some IDs
    links.insert(1, Link::new());
    links.insert(2, Link::new());
    links.insert(3, Link::new());

    // Simulate some response times for each link and public key
    links.get_mut(&1).unwrap().update_history("public_key_1", 1.0);
    links.get_mut(&1).unwrap().update_history("public_key_1", 1.5);
    links.get_mut(&1).unwrap().update_history("public_key_2", 2.0);
    links.get_mut(&1).unwrap().update_history("public_key_2", 2.5);

    links.get_mut(&2).unwrap().update_history("public_key_1", 3.0);
    links.get_mut(&2).unwrap().update_history("public_key_1", 3.5);
    links.get_mut(&2).unwrap().update_history("public_key_2", 4.0);
    links.get_mut(&2).unwrap().update_history("public_key_2", 4.5);

    links.get_mut(&3).unwrap().update_history("public_key_1", 1.2);
    links.get_mut(&3).unwrap().update_history("public_key_1", 1.3);
    links.get_mut(&3).unwrap().update_history("public_key_2", 2.2);
    links.get_mut(&3).unwrap().update_history("public_key_2", 2.3);

    // Select the best link for a given public key
    let best_link_id = select_best_link(&links, "public_key_1", 1000);
    match best_link_id {
        Some(link_id) => {
            report_best_link(link_id);
        }
        None => {
            report_no_link();
        }
    };
}

fn report_best_link(link_id: u32) {
    //println!("Best link {}", link_id);

}

fn report_no_link() {

}
