import os
import lxml.etree as ET

in_path = "Schema"
out_path = "docs"
xsl_path = "stylesheet.xsl"

if not os.path.isdir(out_path):
    os.makedirs(out_path)

xslt = ET.parse(xsl_path)
transform = ET.XSLT(xslt)


def make_index(title: str, dir_links: list[str], file_links: list[str]):
    file_links.sort()
    dir_links.sort()

    content = f"<html><head><title>{title}</title><link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css' /></head><h1>{title}</h1>"

    content += "<h2>Directories</h2>"
    content += "<ul>"
    if title != in_path:
        content += "<li><a href='../'>..</a></li>"
    for link in dir_links:
        content += f"<li><a href='{link}'>{link}</a></li>"
    content += "</ul>"

    content += "<h2>Files</h2>"
    content += "<ul>"
    for link in file_links:
        basename = link.split(".")[0]
        content += f"<li><a href='{link}'>{basename}</a></li>"
    content += "</ul>"

    content += "</html>"
    return content


for path, dirs, files in os.walk(in_path):

    page_dir = os.path.join(out_path, path)
    if not os.path.isdir(page_dir):
        os.makedirs(page_dir)

    file_links = []

    for xsd_file in [f for f in files if f.endswith(".xsd")]:
        base_name = xsd_file.split(".xsd")[0]
        in_file = os.path.join(path, xsd_file)
        html_filename = f"{base_name}.html"
        out_file = os.path.join(out_path, path, html_filename)
        file_links.append(html_filename)

        print(out_file)

        dom = ET.parse(in_file)
        newdom = transform(dom)

        with open(out_file, "wb") as html:
            html.write(ET.tostring(newdom, pretty_print=True))

    with open(os.path.join(out_path, path, "index.html"), "w") as html:
        html.write(make_index(path, dirs, file_links))
