using System;
using System.IO;
using System.Collections.Generic;
using System.Text;

namespace ChargeCardDataProduce
{
    public class CommonHelper
    {
        public static bool SaveToTxtFile(string content, string filepath)
        {
            bool bResult = false;

            string[] paths = filepath.Split(';');

            foreach (string path in paths)
            {
                System.IO.FileStream FS = null;
                System.IO.StreamWriter SW = null;

                try
                {
                    //新建文件流
                    FS = new System.IO.FileStream(path, System.IO.FileMode.Create, System.IO.FileAccess.Write);
                    //建立文件对应的输入流
                    SW = new System.IO.StreamWriter(FS);
                    //向输入流中写入信息
                    SW.WriteLine(content);

                    bResult = true;
                }
                catch(Exception err)
                {
                    Log.Error("生成制卡文件失败" + err.Message, null, "ExpLog");
                }
                finally
                {
                    if (SW != null)
                    {
                        SW.Close();
                    }
                    if (FS != null)
                    {
                        FS.Close();
                    }
                }
            }

            return bResult;
        }

        //public static bool SaveToPublicKeyFile(string corpfilepath, string corpPublicKey)
        //{
        //    bool bResult = false;

        //    System.IO.FileStream FS = null;
        //    System.IO.StreamWriter SW = null;

        //    try
        //    {
        //        //新建文件流
        //        FS = new System.IO.FileStream(corpfilepath, System.IO.FileMode.Create, System.IO.FileAccess.Write);
        //        //建立文件对应的输入流
        //        SW = new System.IO.StreamWriter(FS);
        //        //向输入流中写入信息
        //        SW.WriteLine(corpPublicKey);

        //        bResult = true;
        //    }
        //    catch
        //    {
        //    }
        //    finally
        //    {
        //        if (SW != null)
        //        {
        //            SW.Close();
        //        }
        //        if (FS != null)
        //        {
        //            FS.Close();
        //        }
        //    }

        //    return bResult;
        //}

        public static void DeleteFile(string filepath)
        {
            FileInfo file = new FileInfo(filepath);

            if (file.Exists)
            {
                file.Delete();   //删除单个文件
            }
        }

        public static string ReturnExistSingleFile(string files)
        {
            string[] arrFile = files.Split(';');

            foreach (string file in arrFile)
            {
                if (File.Exists(file))
                {
                    return file;
                }
            }

            return "";
        }

        public static string ReturnExistSinglePath(string paths)
        {
            string[] arrPath = paths.Split(';');

            foreach (string path in arrPath)
            {
                if (Directory.Exists(path))
                {
                    return path;
                }
            }

            return "";
        }

        public static string ReturnExistMultiplyPath(string paths)
        {
            string[] arrPath = paths.Split(';');

            string newpaths = "";

            foreach (string path in arrPath)
            {
                if (Directory.Exists(path))
                {
                    newpaths += path;
                    newpaths += ";";
                }
            }

            if (newpaths != "")
            {
                newpaths = newpaths.Substring(0, newpaths.Length - 1);
            }

            return newpaths;
        }
    }
}
