#/usr/bin/env python3
# -*- coding: utf-8 -*-

import xlrd
import xlwt
import sys
import collections
from datetime import datetime
from xlwt import *
#from functools import reduce 

exel_name = []
def wordcount(str):
    # 文章字符串前期处理
    strl_ist = str.replace('\n', '').lower().split(' ')
    count_dict = {}
    # 如果字典里有该单词则加1，否则添加入字典
    for str in strl_ist:
        if str in count_dict.keys():
            count_dict[str] = count_dict[str] + 1
        else:
            count_dict[str] = 1
    #按照词频从高到低排列
    count_list=sorted(count_dict.iteritems(),key=lambda x:x[1],reverse=True)
    return count_list

def excel_read(excel_name):
    xlrd.Book.encoding = "gbk"
    data = xlrd.open_workbook(excel_name)
    table = data.sheets()[0]

    hs = table.nrows
    ls = table.ncols
    count = 0
    lie = 0
    newlines = []
    rowAC = []
    newsheet_dict = {}
    rowstr_dict = {}
    line_1 = ["名称","规格","标号","封装","数量"]
    for i in range(1,hs):
        #遍历表格的每一行
        lines = table.row_values(i)
        #所有行组成一个二维的列表
        newlines += [lines]
        #第A列和第C列组合成一个字符串
        rowAC += [str(lines[0]) + ',' + str(lines[2])]
        #dict=标号 value=元件+,+封装
        rowstr_dict[str(lines[1])] = str(lines[0]) + ',' + str(lines[2])
    
    #使用counter对 rowAC 列表计数
    #其返回结果为字典
    # #生成元件和标号对应的字典 dict=元件+,+封装 value=标号
    count_dict = collections.Counter(rowAC)
    #for word in rowstr_dict:
    #    print('%-20s %s' %(word,rowstr_dict[word]))
    
    workbook = xlwt.Workbook(encoding = 'gbk', style_compression=0)
    worksheet = workbook.add_sheet('Sheet1')
    style = xlwt.easyxf('font: name 宋体',num_format_str='#,##0') # 初始化样式

    cell_overwrite_ok=True #对一个单元格重复操作
    #savename = excel_name
    for x in line_1:
    	worksheet.write(0,lie,str(x),style)
    	lie += 1
    for word in count_dict:
        strB = ''
        #try:
        #    worksheet.write(count+1,1,str(word.split(',')[0]))
        #except:
        #    worksheet.write(count+1,1,word.split(',')[0])

        for strfoot in rowstr_dict:
            if rowstr_dict[strfoot] == word:
                strB = strB + strfoot + ','
        #newsheet_line[count] = [word.split(',')[0],strB,word.split(',')[1]]
        newsheet_dict[strB.rsplit(',',1)[0]] = word
        #从第2行第4列打印每种材料数量
        #worksheet.write(count+1,4,count_dict[word])
    foot_list = sorted(newsheet_dict,key=str.lower)
    #print(foot_list)
    for foot in foot_list:
        word = newsheet_dict[foot]
        worksheet.write(count+1,2,foot,style)                     #打印第3列
        worksheet.write(count+1,4,count_dict[word],style)
        worksheet.write(count+1,1,str(word.split(',')[0]),style)
        worksheet.write(count+1,3,str(word.split(',')[1]),style)

        count += 1       

    now = datetime.now()

    workbook.save(excel_name.rsplit('.', 1)[0] + '_' + now.strftime('%Y_%m_%d') + '_' + '已整理.xls')

if len(sys.argv) > 1:
    for name in sys.argv[1:]:
        excel_read(name)
