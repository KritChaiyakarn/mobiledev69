"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.contrib.auth import logout
from django.shortcuts import redirect

# สร้าง ฟังก์ชัน Logout สำหรับเคลียร์ Session และ Redirect กลับมา Flutter
def logout_view(request):
    logout(request)
    next_url = request.GET.get('next', 'http://localhost:50000/')
    return redirect(next_url)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('logout/', logout_view, name='logout'),  # <--- เพิ่มบรรทัดนี้
    path('openid/', include('oidc_provider.urls', namespace='oidc_provider')),
    path('api/', include('pets.urls')),  # หรือชื่อ app API ของคุณ
]