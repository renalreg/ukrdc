import os
import lxml.etree as ET

in_path = "Schema"
out_path = "docs"
xsl_path = "doc.xsl"

if not os.path.isdir(out_path):
    os.makedirs(out_path)

xslt = ET.parse(xsl_path)
transform = ET.XSLT(xslt)

for path, dirs, files in os.walk(in_path):
    # Skip root
    if path != in_path:
        page_dir = os.path.join(out_path, path)
        if not os.path.isdir(page_dir):
            os.makedirs(page_dir)

        for xsd_file in [f for f in files if f.endswith(".xsd")]:
            base_name = xsd_file.split(".xsd")[0]
            in_file = os.path.join(path, xsd_file)
            out_file = os.path.join(out_path, path, f"{base_name}.html")
            print(out_file)

            dom = ET.parse(in_file)
            newdom = transform(dom)

            with open(out_file, "wb") as html:
                html.write(ET.tostring(newdom, pretty_print=True))
