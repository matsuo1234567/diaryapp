from django.shortcuts import render
import json
from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
from django.core.files.storage import default_storage

# Create your views here.
@csrf_exempt
def get_img(request):

    if request.method == "POST":
        # ← 受け取ったPOST画像データを保存
            res, file_name = save(request.FILES["image_file"])
            res = request.build_absolute_uri(res) #絶対pathに基づくURLの作成

    else:  # ← methodが'POST'ではない = 最初のページ表示時の処理
        return HttpResponse("this is post page!")

    ret = {"url": res}

    # JSONに変換して戻す
    return JsonResponse(ret)


def save(data):
        file_name = default_storage.save(data.name, data)
        return default_storage.url(file_name), data.name
#受け取ったファイルをストレージに保存
