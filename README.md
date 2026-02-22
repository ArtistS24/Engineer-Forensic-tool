Engineer is a high-performance Bash-based CLI framework designed to automate the triage and analysis of digital evidence. It orchestrates industry-standard tools to perform deep-dive forensics on HDD images, Memory dumps (RAM), and suspicious files through a unified, interactive interface.
Key Features

 One-Click Triage: The Automate HDD and Memory module executes 10+ forensic tools sequentially, generating a comprehensive intelligence report in minutes.

    Memory Forensics: Deep integration with Volatility 3 to extract running processes, network connections, and system registry hives.

    Intelligent Data Carving: Automated file recovery and signature-based extraction using Binwalk, Foremost, and Scalpel.

    Artifact Extraction: Systematic discovery of human-readable data including passwords, URLs, emails, and PCAP files.

    Auto-Environment Setup: Built-in dependency manager that verifies and installs missing forensic packages via apt.

    Evidence Packaging: Persistent logging and structured directory management, with automated ZIP compression for portable evidence sharing.

Integrated Forensic Suite

The framework provides a streamlined interface for:

    Volatility 3: Advanced Memory Analysis.

    Binwalk: Firmware & Embedded File Analysis.

    Bulk Extractor: Feature extraction (PII, Credentials, Network).

    Exiftool: Metadata forensic analysis.

    Stegseek: Steganography detection and cracking.

    Foremost/Scalpel: File system carving and recovery.

Installation & Usage

    Clone the Repository:
    Bash

    git clone https://github.com/AkiraS24/Engineer-Forensic-tool/blob/main/Engineer.sh
    cd Engineer

    Permissions:
    Bash

    chmod +x Engineer.sh

    Launch (Root Required):
    Bash

    sudo ./Engineer.sh

When automation is triggered, the tool organizes findings into a structured hierarchy.
