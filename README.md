# Engineer: Automated Digital Forensics Framework

A high-performance Bash-based forensic CLI framework engineered for automated digital evidence acquisition, memory triage, and file carving across HDD images and volatile memory dumps (RAM).

Developed as part of the Magen Cyber Security curriculum (Class TMagen773634, Module NX212). Official research and project report included as [Engineer.pdf](Engineer.pdf).

---

## Capabilities

- **One-Click Triage Pipeline**: Executes 10+ forensic engines sequentially, builds a unified triage dossier, and packages findings into a portable evidence ZIP archive.
- **Volatile Memory Analysis (Volatility 3)**: Automatic kernel profile identification (Windows & Linux), process trees (`pslist`), network connections (`netscan` / `sockstat`), malware heuristics (`malfind`), and registry hives (`printkey`).
- **Data & Firmware Carving**: Signature-based recovery using Binwalk, Foremost, and Scalpel with automatic directory collision safeguards.
- **PII & Artifact Harvesting**: Bulk Extractor integration recovering credentials, credit cards, emails, URLs, base64 streams, and raw network PCAPs.
- **Deep Text & Steganography**: Automated regex keyword triage (`passwords`, `keys`, `tokens`, `api`, `sessions`) and Stegseek passphrase extraction.
- **Auto-Environment Resolution**: Built-in package verification and apt resolver for zero-friction lab deployment.

---

## Integrated Toolchain

| Category | Tool | Function |
|---|---|---|
| **Memory Forensics** | Volatility 3 | RAM dump analysis, process execution, socket state |
| **Firmware Analysis** | Binwalk | Signature scanning, entropy graphs, extraction |
| **Feature Extraction** | Bulk Extractor | PII, network packets, AES keys, emails, URLs |
| **File Carving** | Foremost / Scalpel | Header/footer carving from raw disk images |
| **Steganography** | Stegseek | Fast passphrase cracking & hidden payload recovery |
| **Metadata Analysis** | Exiftool | EXIF headers, timestamps, filesystem metadata |
| **Low-Level Inspection** | Hexdump / DD | Raw byte offsets, selective partition carving |

---

## Installation & Usage

### 1. Clone Repository
```bash
git clone https://github.com/ArtistS24/Engineer-Forensic-tool.git
cd Engineer-Forensic-tool
```

### 2. Set Permissions
```bash
chmod +x Engineer.sh
```

### 3. Launch Framework (Root Required)
```bash
sudo ./Engineer.sh
```

---

## Evidence Directory Structure

When automated triage completes, evidence is categorized into a structured hierarchy:

```
Engineer/
├── <target_image>/
│   ├── Automation/
│   │   ├── binwalk_<image>.log
│   │   ├── exiftool_<image>.log
│   │   ├── bulk_extractor/ (email.txt, ccn.txt, url.txt, packets.pcap)
│   │   ├── Foremost/ (carved files by extension)
│   │   ├── Scalpel/ (carved files)
│   │   ├── strings_<image>.log (filtered keywords)
│   │   ├── stegseek_<image>.log
│   │   └── volatility/ (pslist, netscan, registry, malfind)
│   └── <target_image>_Automation.zip
```

---

## Author & Academic Reference

- **Author**: Denis Albin ([@ArtistS24](https://github.com/ArtistS24))
- **Student Code**: S24
- **Class**: TMagen773634
- **Project Report**: Included as [Engineer.pdf](Engineer.pdf) (NX212 Digital Forensics & Incident Response)
