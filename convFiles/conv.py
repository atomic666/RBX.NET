import cfscrape
import sys

body = sys.argv[1]
domain = sys.argv[2]

cfs = cfscrape.CloudflareScraper()

print(cfs.solve_challenge(body, domain))
