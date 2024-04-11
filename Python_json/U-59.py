#!/usr/bin/python3
import os
import json

def search_hidden_files_and_directories(start_path):
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-59",
        "위험도": "하",
        "진단 항목": "숨겨진 파일 및 디렉토리 검색 및 제거",
        "진단 결과": "",
        "현황": {"숨겨진 파일": [], "숨겨진 디렉터리": []},
        "대응방안": "불필요하거나 의심스러운 숨겨진 파일 및 디렉터리 삭제"
    }

    for root, dirs, files in os.walk(start_path, topdown=True):
        # Prune directory walk by modifying dirs in-place
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for file in files:
            if file.startswith('.'):
                results["현황"]["숨겨진 파일"].append(os.path.join(root, file))
        for dir in list(dirs):
            if dir.startswith('.'):
                results["현황"]["숨겨진 디렉터리"].append(os.path.join(root, dir))
                dirs.remove(dir)  # Prevent walk into hidden directories

    if not results["현황"]["숨겨진 파일"] and not results["현황"]["숨겨진 디렉터리"]:
        results["진단 결과"] = "양호"
        results["현황"] = "숨겨진 파일이나 디렉터리가 없습니다."
    else:
        results["진단 결과"] = "취약"

    return results

def main():
    home_directory = os.path.expanduser('~')  # Search in the current user's home directory
    hidden_items_check_results = search_hidden_files_and_directories(home_directory)
    print(json.dumps(hidden_items_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

