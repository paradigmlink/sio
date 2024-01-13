use crate::{Index, SingleAssignmentStore};

use hashbrown::HashMap;
use core::hash::Hash;
use core::iter::Iterator;
use hashbrown::hash_map;

#[allow(dead_code)]
///Immutable iterator over each key-value pair. see [`iter`] on [`SingleAssignmentStore`]
/// for more information.
///
/// [`iter`]: SingleAssignmentStore::iter
pub struct Iter<'a, K, V>
where
    K: Hash + Eq,
{
    keys: hash_map::Iter<'a, K, Index>,
    map: &'a HashMap<Index, (usize, V)>,
}

impl<'a, K, V> Iter<'a, K, V>
where
    K: Hash + Eq,
{
    pub fn new(map: &'a SingleAssignmentStore<K, V>) -> Self {
        let keys = map.keys.iter();
        Self {
            keys,
            map: &map.data,
        }
    }
}

impl<'a, K, V> Iterator for Iter<'a, K, V>
where
    K: Hash + Eq,
{
    type Item = (&'a K, &'a V);

    fn next(&mut self) -> Option<Self::Item> {
        match self.keys.next() {
            None => None,
            Some((k, idx)) => self.map.get(idx).map(|(_, v)| (k, v)),
        }
    }
}
