# pyright: basic

import sys
from pathlib import Path
from urllib.parse import unquote

import requests
from bs4 import BeautifulSoup

ROSETTA_CODE_BASE_URL = "https://rosettacode.org"
LOG_FILE = "scrape.log"


def get_rosettacode_links(url: str) -> list[str]:
    html = requests.get(url)
    soup = BeautifulSoup(html.text, "html.parser")
    div = soup.find("div", {"id": "mw-pages"})
    if not div:
        print("Could not find links", file=sys.stderr)
        sys.exit(1)
    # The first and last links are for "next page" or "previous page"
    anchors = div.find_all("a")[1:-1]
    links = [ROSETTA_CODE_BASE_URL + a.get("href") for a in anchors]
    return links


def get_rosettacode_arm_asm(url: str) -> str:
    html = requests.get(url)
    soup = BeautifulSoup(html.text, "html.parser")
    header = soup.find("span", {"id": "ARM_Assembly"})
    # Concatenate all the <pre> tags (in case the code is split across multiple blocks)
    code = ""
    next_node = header
    while True:
        next_node = next_node.next_element
        # Next <h2> tag is probably for a different language
        if next_node.name == "h2":
            if code:
                return code.strip()
            else:
                raise ValueError("No sufficiently long <pre> element found.")
        # There is sometimes a <pre> tag with compilation instructions
        # To ignore that, only include <pre> tags with a certain length
        if next_node.name == "pre":
            code += next_node.text + "\n\n"


def scrape_rosettacode_page(url: str) -> None:
    code = get_rosettacode_arm_asm(url)
    # Use unquote() for URL decoding (e.g., %27)
    problem_name = unquote(
        url.removeprefix(ROSETTA_CODE_BASE_URL + "/wiki/").replace("/", "-")
    )
    dirname = f"arm/rosettacode-{problem_name}/"
    Path(dirname).mkdir(parents=True, exist_ok=True)
    with open(dirname + "code.s", "w", encoding="utf-8") as f:
        f.write(code)


def scrape_rosettacode():
    links = get_rosettacode_links("https://rosettacode.org/wiki/Category:ARM_Assembly")
    links += get_rosettacode_links(
        "https://rosettacode.org/w/index.php?title=Category:ARM_Assembly&pagefrom=Totient+function"
    )

    print(f"Found {len(links)} pages on Rosetta Code.")
    for link in links:
        print(f"Scraping '{link}'... ", end="")
        sys.stdout.flush()
        try:
            scrape_rosettacode_page(link)
            print("Done.")
        except Exception as e:
            print(f"Error: see {LOG_FILE} for details.")
            with open(LOG_FILE, "a") as f:
                f.write(f"Error while scraping '{link}':\n{e}\n\n")


def clear_logs():
    with open(LOG_FILE, "w"):
        pass


def main():
    clear_logs()
    scrape_rosettacode()


if __name__ == "__main__":
    main()
