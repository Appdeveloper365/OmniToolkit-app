/// FILE: lib/modules/lookup/data/zip_seed_data.dart
import '../models/zip_entry.dart';

/// Fallback seed dataset used if the bundled SQLite table or CSV is missing.
const List<ZipEntry> zipSeedData = [
  ZipEntry(zip: '17111', city: 'Harrisburg', state: 'PA', county: 'Dauphin', areaCodes: ['717', '223'], region: ['Harrisburg, PA'], timezone: 'America/New_York', lat: 40.26895, lng: -76.78491),
  ZipEntry(zip: '10001', city: 'New York', state: 'NY', county: 'New York County', areaCodes: ['212', '646', '332'], region: ['NYC Metro'], timezone: 'America/New_York', lat: 40.7506, lng: -73.9972),
  ZipEntry(zip: '90210', city: 'Beverly Hills', state: 'CA', county: 'Los Angeles County', areaCodes: ['310', '424'], region: ['Los Angeles, CA'], timezone: 'America/Los_Angeles', lat: 34.0901, lng: -118.4065),
  ZipEntry(zip: '30301', city: 'Atlanta', state: 'GA', county: 'Fulton County', areaCodes: ['404', '678', '470'], region: ['Atlanta, GA'], timezone: 'America/New_York', lat: 33.7550, lng: -84.3900),
  ZipEntry(zip: '90001', city: 'Los Angeles', state: 'CA', county: 'Los Angeles County', areaCodes: ['213', '323'], region: ['Los Angeles, CA'], timezone: 'America/Los_Angeles', lat: 33.9731, lng: -118.2479),
  ZipEntry(zip: '60601', city: 'Chicago', state: 'IL', county: 'Cook County', areaCodes: ['312', '872'], region: ['Chicago, IL'], timezone: 'America/Chicago', lat: 41.8858, lng: -87.6229),
  ZipEntry(zip: '77001', city: 'Houston', state: 'TX', county: 'Harris County', areaCodes: ['713', '281', '832'], region: ['Houston, TX'], timezone: 'America/Chicago', lat: 29.7752, lng: -95.3654),
  ZipEntry(zip: '85001', city: 'Phoenix', state: 'AZ', county: 'Maricopa County', areaCodes: ['602', '623'], region: ['Phoenix, AZ'], timezone: 'America/Phoenix', lat: 33.4484, lng: -112.0740),
  ZipEntry(zip: '19101', city: 'Philadelphia', state: 'PA', county: 'Philadelphia County', areaCodes: ['215', '267'], region: ['Philadelphia, PA'], timezone: 'America/New_York', lat: 39.9523, lng: -75.1638),
  ZipEntry(zip: '94101', city: 'San Francisco', state: 'CA', county: 'San Francisco County', areaCodes: ['415', '628'], region: ['San Francisco, CA'], timezone: 'America/Los_Angeles', lat: 37.7749, lng: -122.4194),
  ZipEntry(zip: '98101', city: 'Seattle', state: 'WA', county: 'King County', areaCodes: ['206'], region: ['Seattle, WA'], timezone: 'America/Los_Angeles', lat: 47.6101, lng: -122.3344),
  ZipEntry(zip: '20001', city: 'Washington', state: 'DC', county: 'District of Columbia', areaCodes: ['202'], region: ['Washington, DC'], timezone: 'America/New_York', lat: 38.9109, lng: -77.0163),
  ZipEntry(zip: '02101', city: 'Boston', state: 'MA', county: 'Suffolk County', areaCodes: ['617', '857'], region: ['Boston, MA'], timezone: 'America/New_York', lat: 42.3588, lng: -71.0567),
  ZipEntry(zip: '33101', city: 'Miami', state: 'FL', county: 'Miami-Dade County', areaCodes: ['305', '786'], region: ['Miami, FL'], timezone: 'America/New_York', lat: 25.7743, lng: -80.1937),
];
