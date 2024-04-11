#!/usr/bin/python3
import subprocess
import os
import json

def check_unnecessary_web_files_removal():
    results = {
        "분류": "서비스 관리",
        "코드": "U-38",
        "위험도": "상",
        "진단 항목": "웹서비스 불필요한 파일 제거",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "기본으로 생성되는 불필요한 파일 및 디렉터리 제거"
    }

    # Example locations for IBM HTTP Server configuration and content
    serverroot_directories = [
        "/usr/IBM/HTTPServer/htdocs",  # Adjust as necessary
    ]

    # Common unnecessary file or directory names to check for removal
    unnecessary_items = ["manual", "cgi-bin", "icons"]

    vulnerable = False
    for directory in serverroot_directories:
        for item in unnecessary_items:
            item_path = os.path.join(directory, item)
            if os.path.exists(item_path):
                results["진단 결과"] = "취약"
                results["현황"].append(f"웹서비스 디렉터리 내 불필요한 파일 또는 디렉터리가 제거되어 있지 않습니다: {item_path}")
                vulnerable = True
                # If one unnecessary item is found, no need to check others
                break
        if vulnerable:
            # If one serverroot directory is vulnerable, no need to check others
            break

    if not vulnerable:
        results["진단 결과"] = "양호"
        results["현황"].append("웹서비스 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있습니다.")

    return results

def main():
    results = check_unnecessary_web_files_removal()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
