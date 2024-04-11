#!/usr/bin/python3
import subprocess
import os
import json

def check_web_service_directory_listing():
    results = {
        "분류": "서비스 관리",
        "코드": "U-35",
        "위험도": "상",
        "진단 항목": "웹서비스 디렉토리 리스팅 제거",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "디렉터리 검색 기능 사용하지 않기"
    }

    # Example paths where IBM HTTP Server configuration files might reside
    common_paths = [
        "/usr/IBM/HTTPServer/conf",  # Common path for IBM HTTP Server
        "/etc/httpd/conf",  # Standard Apache path, included for completeness
    ]

    webconf_files = ["httpd.conf", "apache2.conf"]
    vulnerable = False

    for path in common_paths:
        for conf_file in webconf_files:
            file_path = os.path.join(path, conf_file)
            if os.path.isfile(file_path):
                with open(file_path, 'r') as file:
                    content = file.read()
                    if "options indexes" in content.lower() and "-indexes" not in content.lower():
                        results["진단 결과"] = "취약"
                        results["현황"].append(f"{file_path} 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
                        vulnerable = True
                        break  # Stop checking further if vulnerability found
        if vulnerable:
            break  # Stop checking other common paths if vulnerability found

    if not vulnerable:
        results["진단 결과"] = "양호"
        results["현황"].append("웹서비스 디렉터리 리스팅이 적절히 제거되었습니다.")

    return results

def main():
    results = check_web_service_directory_listing()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
