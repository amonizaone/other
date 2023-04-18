using AutoMapper;
using AutoMapper.QueryableExtensions;
using intership.service;
using intership.common;
using intership.data.Models.Context;
using intership.data.Models.Form;
using intership.data.Models.Share;
using intership.data.Models.View;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using intership.common.Pages;
using StoredProcedureEFCore;
using ZXing;
using static intership.api.Reports.DataSet.ReportDataSet;
using Microsoft.Data.SqlClient;
using intership.service.ReptService;

namespace intership.api.Controllers.v1
{
    [ApiController]
    [ApiVersion("1.0")]
    [Route("v{version:apiVersion}/reports")]
    public class ReportController : Controller
    {
        #region field
        private readonly InspDbContext inspDbContext;
        private readonly IMapper mapper;
        private readonly ILogger<SettingController> logger;
        private readonly IOptions<InitailAppSettingsModel> options;
        private readonly IHttpContextAccessor httpContextAccessor;
        private readonly IWebHostEnvironment webHostEnvironment;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ISSRSRender _ssrs;

        //private readonly ISSRSRender iSSRSRender;
        #endregion field

        #region constructor

        public ReportController
        (
            IHttpContextAccessor _httpContextAccessor,
            ILogger<SettingController> _logger,
            IMapper _mapper,
            IOptions<InitailAppSettingsModel> _options,
            InspDbContext _inspDbContext,
            IHttpClientFactory httpClientFactory,
            IWebHostEnvironment _webHostEnvironment
        // ISSRSRender ssrs
        //ISSRSRender _iSSRSRender
        )
        {
            options = _options;
            inspDbContext = _inspDbContext;
            httpContextAccessor = _httpContextAccessor;
            logger = _logger;
            mapper = _mapper;
            //iSSRSRender = _iSSRSRender;
            _ssrs = new SSRSRender(options);
            webHostEnvironment = _webHostEnvironment;
            _httpClientFactory = httpClientFactory;
        }

        #endregion constructor

        [HttpGet("export-label")]
        [Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> GetAttachmentShipment(string shipmentNo, string fileName, int fm = 1, int to = 500, int total = 500)
        {
            try
            {
                List<byte[]> outOfFile = new();
                // logger.LogDebug("Http Request: GetAttachmentShipment {@Request}", Request);
                var reportServer = options.Value.ReportServer;
                Uri uri = new(reportServer.Host);

                CredentialCache credentialCache = new()
                {
                    { new Uri(uri.ToString()), "NTLM", new(reportServer.Username, reportServer.Password) }
                };

                NameValueCollection paramsColection = new()
                {
                    { "ShipmentNo", shipmentNo }
                };
                //HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
                paramsColection.Remove("reportName");
                paramsColection.Remove("format");

                int totalItems = to < total ? to : total;

                int limitPerpage = totalItems > 100 ? 100 : totalItems;

                Pager pageOpt = new(totalItems, fm, to, limitPerpage);

                int cur = pageOpt.CurrentPage;
                int pageSize = pageOpt.PageSize;

                for (int k = 0; k < pageOpt.TotalPages; k++)
                {

                    paramsColection.Set("PageNumber", cur.ToString());
                    paramsColection.Set("RowsOfPage", pageSize.ToString());

                    string reportPath = $"{reportServer.Path}/{fileName}";

                    var result = await _ssrs.RenderReport(reportPath, paramsColection);
                    outOfFile.Add(result);
                    cur++;

                    pageOpt = new(totalItems, cur, to, limitPerpage);
                }

                // var result = await _ssrs.RenderReport($"{reportServer.Path}/{fileName}", paramsColection);
                var mergePdf = PdfHelper.MergePdf(outOfFile);

                return File(mergePdf, $"application/pdf", $"LABEL-{shipmentNo}.pdf");
            }
            catch (Exception e)
            {
                logger.LogDebug($"Error: {(e.InnerException != null ? e.InnerException.Message : e.Message)}");
                throw e;
            }


        }

        [HttpGet("pagined/export-label")]
        [Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> GetAttachmentShipmentPagined(string shipmentNo, string fileName, int currentPage = 1, int pageOffset = 100)
        {
            try
            {
                List<byte[]> outOfFile = new();
                // logger.LogDebug("Http Request: GetAttachmentShipment {@Request}", Request);
                var reportServer = options.Value.ReportServer;
                Uri uri = new(reportServer.Host);

                CredentialCache credentialCache = new()
                {
                    { new Uri(uri.ToString()), "NTLM", new(reportServer.Username, reportServer.Password) }
                };

                NameValueCollection paramsColection = new()
                {
                    { "ShipmentNo", shipmentNo }
                };
                //HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
                paramsColection.Remove("reportName");
                paramsColection.Remove("format");


                paramsColection.Set("PageNumber", currentPage.ToString());
                paramsColection.Set("RowsOfPage", pageOffset.ToString());

                string reportPath = $"{reportServer.Path}/{fileName}";

                var result = await _ssrs.RenderReport(reportPath, paramsColection);
                outOfFile.Add(result);


                // var result = await _ssrs.RenderReport($"{reportServer.Path}/{fileName}", paramsColection);
                var mergePdf = PdfHelper.MergePdf(outOfFile);

                return File(mergePdf, $"application/pdf", $"LABEL-{shipmentNo}.pdf");
            }
            catch (Exception e)
            {
                logger.LogDebug($"Error: {(e.InnerException != null ? e.InnerException.Message : e.Message)}");
                throw e;
            }


        }
        //[HttpGet("export-label")]
        //[Authorize]
        //[SwaggerResponse(200, "Success", typeof(File))]
        //[SwaggerResponse(400, "Bad Request")]
        //[SwaggerResponse(401, "Unauthorized")]
        //[SwaggerResponse(404, "Not Found")]
        //[SwaggerResponse(500, "Internal Server Error")]
        //[SwaggerResponseExample(200, typeof(File))]
        //public async Task<ActionResult> GetAttachmentShipment(string shipmentNo, string fileName)
        //{
        //    var reportServer = options.Value.ReportServer;
        //    Uri uri = new Uri(reportServer.Host);
        //    //var sSRSDownloader  = SSRSDownloader
        //    try
        //    {


        //        NameValueCollection paramsColection = new NameValueCollection
        //    {
        //        {"ShipmentNo",shipmentNo }
        //    };
        //        //HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
        //        paramsColection.Remove("reportName");
        //        paramsColection.Remove("format");

        //        SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory);

        //        var result = await sSRS.RenderReport($"{reportServer.Path}/{fileName}", paramsColection);
        //        return File(result, $"application/pdf", $"LABEL-{shipmentNo}.pdf");
        //    }
        //    catch (Exception e)
        //    {
        //        throw e;
        //    }

        [HttpPost("pagined/export-label")]
        //[Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostAttachmentShipmentPages([FromBody] FormReportRequest formReport, int currentPage = 1, int pageOffset = 100)
        {
            try
            {

                var reportServer = options.Value.ReportServer;
                Uri uri = new(reportServer.Host);

                List<byte[]> outOfFile = new();


                //int limit = 10;
                //for (int i = 0; i < formReport.Parameters.Count; i += 10)
                //{


                string shipmentNoJoin = "";

                //var inputParams = formReport.Parameters.Skip(i).Take(limit).ToList();

                var takeShipment = formReport.Parameters;

                shipmentNoJoin = string.Join(",", takeShipment.Select(x => x.Value));

                NameValueCollection paramsColection = new()
                {
                    { "ShipmentNo", shipmentNoJoin }
                };


                paramsColection.Remove("reportName");
                paramsColection.Remove("format");


                paramsColection.Set("PageNumber", currentPage.ToString());
                paramsColection.Set("RowsOfPage", pageOffset.ToString());

                string reportPath = $"{reportServer.Path}/{formReport.ReportName}";

                var result = await _ssrs.RenderReport(reportPath, paramsColection);
                outOfFile.Add(result);


                //Do something with 100 or remaining items
                //}
                var mergePdf = PdfHelper.MergePdf(outOfFile);
                return File(mergePdf, $"application/pdf", $"Shipments-{DateTime.Now:yyyyMMddHHmm}.pdf");
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResponseMessageLocale()
                {
                    Message = new LocaleViewModel
                    {
                        Th = DefaultValues.Error["Th"],
                        En = DefaultValues.Error["En"],
                    },
                    Results = "CODE: 500 " + (ex.InnerException != null ? ex.InnerException.Message : ex.Message),
                    Code = "Report"
                });
            }

        }



        [HttpPost("pagined/local/export-label")]
        //[Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostAttachmentShipmentLocalPages([FromBody] FormReportRequest formReport, string pathx = null, int currentPage = 1, int pageOffset = 100, string toType = "pdf")
        {
            try
            {

                var reportServer = options.Value.ReportServer;
                Uri uri = new(reportServer.Host);

                List<byte[]> outOfFile = new();


                //int limit = 10;
                //for (int i = 0; i < formReport.Parameters.Count; i += 10)
                //{


                string shipmentNoJoin = "";

                //var inputParams = formReport.Parameters.Skip(i).Take(limit).ToList();

                var takeShipment = formReport.Parameters;

                shipmentNoJoin = string.Join(",", takeShipment.Select(x => x.Value));

                NameValueCollection paramsColection = new()
                {
                    { "ShipmentNo", shipmentNoJoin }
                };

                var dataTable = LoadDatatSetFromStored("sp_InterShip_Get_LBL-001-02", formReport.Parameters, pageOffset);

                paramsColection.Remove("reportName");
                paramsColection.Remove("format");

                paramsColection.Set("PageNumber", currentPage.ToString());
                paramsColection.Set("RowsOfPage", pageOffset.ToString());

                string reportPath = $"{reportServer.Path}/{formReport.ReportName}";

                var result = await _ssrs.RenderLocal(formReport.ReportName, pathx, new List<RequestDataSet> {
                    new RequestDataSet{
                        Name ="DataSet1",
                        Value= dataTable,

                    },
                }, paramsColection, formReport.ReportType);


                byte[] outOfFileFirst = result;
                if (formReport.ReportType.ToUpper() == "IMAGE")
                {
                    outOfFileFirst = PdfHelper.PdfViaImage2(new MemoryStream(result));
                }


                string reportName = $"Shipments-{DateTime.Now:yyyyMMddHHmm}.{toType}";


                return File(outOfFileFirst, "application/pdf", $"{reportName}");
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResponseMessageLocale()
                {
                    Message = new LocaleViewModel
                    {
                        Th = DefaultValues.Error["Th"],
                        En = DefaultValues.Error["En"],
                    },
                    Results = "CODE: 500 " + (ex.InnerException != null ? ex.InnerException.Message : ex.Message),
                    Code = "Report"
                });
            }

        }



        [HttpPost("export-label")]
        //[Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostAttachmentShipment([FromBody] FormReportRequest formReport, int fm = 1, int to = 500, int total = 500)
        {
            try
            {

                if (to > total) return BadRequest();

                var reportServer = options.Value.ReportServer;
                Uri uri = new(reportServer.Host);

                List<byte[]> outOfFile = new();


                //int limit = 10;
                //for (int i = 0; i < formReport.Parameters.Count; i += 10)
                //{


                string shipmentNoJoin = "";

                //var inputParams = formReport.Parameters.Skip(i).Take(limit).ToList();

                var takeShipment = formReport.Parameters.Take(total);

                shipmentNoJoin = string.Join(",", takeShipment.Select(x => x.Value));

                NameValueCollection paramsColection = new()
                {
                    { "ShipmentNo", shipmentNoJoin }
                };


                paramsColection.Remove("reportName");
                paramsColection.Remove("format");



                int totalItems = to < total ? to : total;

                int limitPerpage = 100;

                Pager pageOpt = new(totalItems, fm, to, limitPerpage);

                int cur = pageOpt.CurrentPage;
                int pageSize = pageOpt.PageSize;

                for (int k = 0; k < pageOpt.TotalPages; k++)
                {

                    paramsColection.Set("PageNumber", cur.ToString());
                    paramsColection.Set("RowsOfPage", pageSize.ToString());

                    string reportPath = $"{reportServer.Path}/{formReport.ReportName}";

                    var result = await _ssrs.RenderReport(reportPath, paramsColection);
                    outOfFile.Add(result);
                    cur++;

                    pageOpt = new(totalItems, cur, to, limitPerpage);
                }


                //Do something with 100 or remaining items
                //}
                var mergePdf = PdfHelper.MergePdf(outOfFile);
                return File(mergePdf, $"application/pdf", $"Shipments-{DateTime.Now:yyyyMMddHHmm}.pdf");
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResponseMessageLocale()
                {
                    Message = new LocaleViewModel
                    {
                        Th = DefaultValues.Error["Th"],
                        En = DefaultValues.Error["En"],
                    },
                    Results = "CODE: 500 " + (ex.InnerException != null ? ex.InnerException.Message : ex.Message),
                    Code = "Report"
                });
            }

        }



        //[HttpPost("export-label")]
        ////[Authorize]
        //[SwaggerResponse(200, "Success", typeof(File))]
        //[SwaggerResponse(400, "Bad Request")]
        //[SwaggerResponse(401, "Unauthorized")]
        //[SwaggerResponse(404, "Not Found")]
        //[SwaggerResponse(500, "Internal Server Error")]
        //[SwaggerResponseExample(200, typeof(File))]
        //public async Task<ActionResult> PostAttachmentShipment([FromBody] FormReportRequest formReport, int fm = 1, int to = 500, int total = 500)
        //{
        //    try
        //    {

        //        if (to > total) return BadRequest();

        //        var reportServer = options.Value.ReportServer;
        //        Uri uri = new(reportServer.Host);

        //        List<byte[]> outOfFile = new();


        //        //int limit = 10;
        //        //for (int i = 0; i < formReport.Parameters.Count; i += 10)
        //        //{

        //        string shipmentNoJoin = "";

        //        //var inputParams = formReport.Parameters.Skip(i).Take(limit).ToList();

        //        var takeShipment = formReport.Parameters.Take(total);

        //        shipmentNoJoin = string.Join(",", takeShipment.Select(x => x.Value));

        //        NameValueCollection paramsColection = new()
        //        {
        //            { "ShipmentNo", shipmentNoJoin }
        //        };


        //        paramsColection.Remove("reportName");
        //        paramsColection.Remove("format");


        //        int totalItems = to < total ? to : total;

        //        int limitPerpage = totalItems > 100 ? 100 : totalItems;

        //        Pager pageOpt = new(totalItems, fm, to, limitPerpage);

        //        int cur = pageOpt.CurrentPage;
        //        int pageSize = pageOpt.PageSize;

        //        for (int k = 0; k < pageOpt.TotalPages; k++)
        //        {

        //            paramsColection.Set("PageNumber", cur.ToString());
        //            paramsColection.Set("RowsOfPage", pageSize.ToString());

        //            string reportPath = $"{reportServer.Path}/{formReport.ReportName}";

        //            var result = await _ssrs.RenderReport(reportPath, paramsColection);
        //            outOfFile.Add(result);
        //            cur++;

        //            pageOpt = new(totalItems, cur, to, limitPerpage);
        //        }


        //        //Do something with 100 or remaining items
        //        //}
        //        var mergePdf = PdfHelper.MergePdf(outOfFile);
        //        return File(mergePdf, $"application/pdf", $"Shipments-{DateTime.Now:yyyyMMddHHmm}.pdf");
        //    }
        //    catch (Exception ex)
        //    {
        //        return StatusCode(500, new ResponseMessageLocale()
        //        {
        //            Message = new LocaleViewModel
        //            {
        //                Th = DefaultValues.Error["Th"],
        //                En = DefaultValues.Error["En"],
        //            },
        //            Results = "CODE: 500 " + (ex.InnerException != null ? ex.InnerException.Message : ex.Message),
        //            Code = "Report"
        //        });
        //    }

        //}




        private byte[] GernerateReport(List<RequestParams> requestParams, int take = 1, int limit = 1)
        {
            List<byte> outOfFile = new();
            for (int i = 0; i < requestParams.Count; i += 5)
            {
            }

            return outOfFile.ToArray();
        }

        //private FileResult DownloadMultipleFiles(List<byte[]> byteArrayList)
        //{
        //    var zipName = $"archive-EvidenceFiles-{DateTime.Now.ToString("yyyy_MM_dd-HH_mm_ss")}.zip";
        //    using (MemoryStream ms = new())
        //    {
        //        using (var archive = new System.IO.Compression.ZipArchive(ms, System.IO.Compression.ZipArchiveMode.Create, true))
        //        {
        //            foreach (var file in byteArrayList)
        //            {
        //                string fPath = Encoding.ASCII.GetString(file);
        //                var entry = archive.CreateEntry(System.IO.Path.GetFileName(fPath), System.IO.Compression.CompressionLevel.Fastest);
        //                using (var zipStream = entry.Open())
        //                {
        //                    var bytes = System.IO.File.ReadAllBytes(fPath);
        //                    zipStream.Write(bytes, 0, bytes.Length);
        //                }
        //            }
        //        }
        //        return File(ms.ToArray(), "application/zip", zipName);
        //    }
        //}
        [HttpGet("export-manifest/{manifestNo}")]
        [Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> GetAttachmentManifest(string manifestNo, string reportName)
        {
            // logger.LogDebug("Http Request: GetAttachmentManifest {@Request}", Request);
            var reportServer = options.Value.ReportServer;
            Uri uri = new Uri(reportServer.Host);
            //reportName = "ManifestReport";
            //CredentialCache credentialCache = new CredentialCache
            //{
            //    { new Uri(uri.ToString()), "NTLM", new NetworkCredential(reportServer.Username, reportServer.Password) }
            //};

            NameValueCollection paramsColection = HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
            paramsColection.Remove("reportName");
            paramsColection.Remove("format");
            paramsColection.Add("ManifestNo", manifestNo);
            //SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory, reportServer);

            var result = await _ssrs.RenderReport($"{reportServer.Path}/{reportName}", paramsColection);
            //logger.LogDebug($"Response: {result}");

            return File(result, $"application/pdf", $"Manifest-{manifestNo}.pdf");

        }


        [HttpGet("export")]
        [Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> ExportAttachmentFile(string reportName, string format = "pdf")
        {
            try
            {
                // logger.LogDebug("Http Request: {@Request}", Request);
                var reportServer = options.Value.ReportServer;
                Uri uri = new(reportServer.Host);
                //UriBuilder uriBuilder = new UriBuilder
                //{
                //    Scheme = uri.Scheme,
                //    Host = $"{uri.Host}{uri.AbsolutePath}",
                //};
                ////uriBuilder.Query = $"{uri.Query}/ManifestReport/&ManifestNo={manifestNo}&rs:Format=pdf";
                //CredentialCache credentialCache = new CredentialCache
                //{
                //    { new Uri(uri.ToString()), "NTLM", new NetworkCredential(reportServer.Username, reportServer.Password) }
                //};

                NameValueCollection paramsColection = HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());

                // var getContainReportName = inspDbContext.MasterCustomerReports
                //.FirstOrDefault(x => x.SsrsReportName != null && x.CustomerId == loggedInCustomerId
                //&& x.SsrsReportName.Contains(formReport.ReportName) && x.DeletedFlag != "Y");
                // if (getContainReportName != null)
                // {
                //     formReport.ReportName = getContainReportName.SsrsReportName;
                // }

                paramsColection.Remove("reportName");
                paramsColection.Remove("format");

                //SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory, reportServer);




                //var IsfileContent = new FileExtensionContentTypeProvider().TryGetContentType(fileName, out string contentType);
                var result = await _ssrs.RenderReport($"{reportServer.Path}/{reportName}", paramsColection);

                var fileResult = FileStreem(format, result);
                string fileName = $"Export-{reportName}{DateTime.Now:yyyyMMddHHmm}.{fileResult.FileType}";
                //logger.LogDebug($"Response: {result}");

                return File(result, $"{fileResult.ContentType}", fileName);

            }
            catch (Exception e)
            {
                logger.LogError("Exception: {@exception}", e);
                throw e;
            }

            //using (HttpClient client = new HttpClient(new HttpClientHandler
            //{
            //    Credentials = credentialCache
            //}))
            //{

            //    client.BaseAddress = new Uri(uriBuilder.ToString());
            //    client.DefaultRequestHeaders.Accept.Clear();
            //    HttpResponseMessage response = await client.GetAsync(uriBuilder.ToString());

            //    if (response.IsSuccessStatusCode)
            //    {
            //        System.Net.Http.HttpContent content = response.Content;
            //        var contentStream = await content.ReadAsStreamAsync(); // get the actual content stream

            //    }
            //    else
            //    {
            //        throw new FileNotFoundException();
            //    }
            //}

        }

        [HttpPost("export")]
        [Authorize]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostAttachmentFile([FromBody] FormReportRequest formReport)
        {
            JwtClaim _jwt = new(httpContextAccessor);
            int? loggedInCustomerId = _jwt.Get("CustomerId");
            string loggedInCustomerCode = _jwt.Get("CustomerCode");

            var reportServer = options.Value.ReportServer;
            Uri uri = new(reportServer.Host);

            NameValueCollection paramsColection = new();

            //var getContainReportName = inspDbContext.MasterCustomerReports
            //    .FirstOrDefault(x => x.SsrsReportName != null && x.CustomerId == loggedInCustomerId
            //    && x.SsrsReportName.Contains(formReport.ReportName) && x.DeletedFlag != "Y");
            //if (getContainReportName != null)
            //{
            //    formReport.ReportName = getContainReportName.SsrsReportName;
            //}

            formReport.Parameters.ForEach(i => paramsColection.Add(i.Name, i.Value?.ToString() ?? ""));


            //HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
            paramsColection.Remove("reportName");
            paramsColection.Remove("format");

            //SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory, reportServer);
            //TEST
            var result = await _ssrs.RenderReport($"{reportServer.Path}/{formReport.ReportName}", paramsColection, formReport.ReportType);
            //return File(result, $"application/pdf", $"Shipments-{DateTime.Now:yyyyMMddHHmm}.pdf");
            //string mapReportType = formReport.ReportType.ToUpper() == "EXCEL" ? "xlsx" : formReport.ReportType;

            //var IsfileContent = new FileExtensionContentTypeProvider().TryGetContentType(fileName, out string contentType);
            var fileResult = FileStreem(formReport.ReportType, result);
            string fileName = $"Export-{formReport.ReportName}{DateTime.Now:yyyyMMddHHmm}.{fileResult.FileType}";

            return File(fileResult?.FileByte ?? new byte[1024], $"{fileResult.ContentType}", fileName);
        }


        #region our service

        [HttpPost("our/export")]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostAttachmentFilePublic([FromBody] FormReportRequest formReport)
        {

            var reportServer = options.Value.ReportServer;
            Uri uri = new(reportServer.Host);

            NameValueCollection paramsColection = new()
            {

            };

            formReport.Parameters.ForEach(i => paramsColection.Add(i.Name, i.Value.ToString()));


            paramsColection.Remove("reportName");
            paramsColection.Remove("format");

            //SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory, reportServer);
            //TEST
            var result = await _ssrs.RenderReport($"{reportServer.Path}/{formReport.ReportName}", paramsColection, formReport.ReportType);

            //var IsfileContent = new FileExtensionContentTypeProvider().TryGetContentType(fileName, out string contentType);
            var fileResult = FileStreem(formReport.ReportType, result);
            string fileName = $"Export-{formReport.ReportName}{DateTime.Now:yyyyMMddHHmm}.{fileResult.FileType}";

            return File(fileResult?.FileByte ?? new byte[1024], $"{fileResult.ContentType}", fileName);
        }

        [HttpGet("our/export-manifest/{manifestNo}")]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> GetAttachmentManifestOut(string manifestNo, string reportName)
        {
            // logger.LogDebug("Http Request: GetAttachmentManifestOut {@Request}", Request);
            var reportServer = options.Value.ReportServer;
            Uri uri = new Uri(reportServer.Host);

            NameValueCollection paramsColection = HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
            paramsColection.Remove("reportName");
            paramsColection.Remove("format");
            paramsColection.Add("ManifestNo", manifestNo);
            //SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory, reportServer);

            var result = await _ssrs.RenderReport($"{reportServer.Path}/{reportName}", paramsColection);
            logger.LogDebug($"Response: {result}");

            return File(result, $"application/pdf", $"Manifest-{manifestNo}.pdf");

        }

        [HttpPost("our/export-label")]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostAttachmentShipmentOur([FromBody] FormReportRequest formReport, int maxResult = 500)
        {
            try
            {
                var reportServer = options.Value.ReportServer;
                Uri uri = new Uri(reportServer.Host);
                string shipmentNoJoin = string.Join(",", formReport.Parameters.Select(x => x.Value));

                NameValueCollection paramsColection = new NameValueCollection
            {
                {"ShipmentNo",shipmentNoJoin }
            };
                //HttpUtility.ParseQueryString(HttpContext.Request.QueryString.ToString());
                paramsColection.Remove("reportName");
                paramsColection.Remove("format");

                //SSRSRender sSRS = new SSRSRender(reportServer.Host, _httpClientFactory, reportServer);

                var result = await _ssrs.RenderReport($"{reportServer.Path}/{formReport.ReportName}", paramsColection);
                return File(result, $"application/pdf", $"Shipments-{DateTime.Now:yyyyMMddHHmm}.pdf");
            }
            catch (Exception e)
            {

                throw e;
            }

        }
        #endregion our service
        private FileStreemDynamic FileStreem(string format, byte[] report)
        {
            string fileType = "PDF";
            string contentType = string.Format("application/{0}", format);
            using MemoryStream ms = new MemoryStream(report);
            switch (format)
            {
                case "PDF":
                    contentType = "application/pdf";
                    break;
                case "DOCX":
                    contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                    break;
                case "XLS":
                case "EXCELOPENXML":
                    contentType = "application/vnd.ms-excel";
                    fileType = "xls";
                    break;
                case "XLSX":
                case "EXCEL":
                    contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                    fileType = "xlsx";
                    break;
                case "RTF":
                    break;
                case "MHT":
                    contentType = "message/rfc822";
                    break;
                case "HTML":
                    contentType = "text/html";
                    break;
                case "TXT":
                    contentType = "text/plain";
                    break;
                case "CSV":
                    contentType = "text/plain";
                    break;
                case "PNG":
                case "IMAGE":
                case "JPG":
                case "JPGE":
                    contentType = "image/png";
                    fileType = "png";
                    //report.ExportToImage(ms, new ImageExportOptions() { Format = System.Drawing.Imaging.ImageFormat.Png });
                    break;
                default:
                    fileType = format;
                    break;
            }

            return new FileStreemDynamic() { FileByte = ms.ToArray(), ContentType = contentType, FileType = fileType };
        }



        [HttpPost("export/operationArea")]
        [SwaggerResponse(200, "Success", typeof(File))]
        [SwaggerResponse(400, "Bad Request")]
        [SwaggerResponse(401, "Unauthorized")]
        [SwaggerResponse(404, "Not Found")]
        [SwaggerResponse(500, "Internal Server Error")]
        [SwaggerResponseExample(200, typeof(File))]
        public async Task<ActionResult> PostOpearationAreaFile([FromBody] FormReportRequest formReport)
        {
            JwtClaim _jwt = new(httpContextAccessor);
            string loggedInCustomerCode = _jwt.Get("keyword");

            var reportServer = options.Value.ReportServer;
            Uri uri = new(reportServer.Host);

            NameValueCollection paramsColection = new();
            formReport.Parameters.ForEach(i => paramsColection.Add(i.Name, i.Value?.ToString() ?? ""));
            paramsColection.Remove("reportName");
            paramsColection.Remove("format");

            //logger.LogDebug($"Response: {result}");



            var result = await _ssrs.RenderReport($"{reportServer.Path}/{formReport.ReportName}", paramsColection, formReport.ReportType);

            var fileResult = FileStreem(formReport.ReportType, result);
            string fileName = $"Export-{formReport.ReportName}{DateTime.Now:yyyyMMddHHmm}.{fileResult.FileType}";

            return File(fileResult?.FileByte ?? new byte[1024], $"{fileResult.ContentType}", fileName);
        }


        private DataTable LoadDatatSetFromStored(string storedName, List<RequestParams> requestParams, int totalPackage)
        {
            // requestParams
            DataTable dataTable = new();
            //List<DataTable> shipments = new();
            var shipmentNoJoin = string.Join(",", requestParams.Select(x => x.Value));
            //inspDbContext.LoadStoredProc($"dbo.{storedName}")
            //   .AddParam("ShipmentNo", shipmentNoJoin)
            //   .AddParam("PageNumber", 1)
            //   .AddParam("RowsOfPage", totalPackage)

            //   .Exec(r => shipments = r.ToList<DataTable>());

            using (SqlConnection sqlcon = new(inspDbContext.Database.GetConnectionString()))
            {
                using (SqlCommand cmd = new($"{storedName}", sqlcon))
                {
                    cmd.Parameters.AddWithValue("ShipmentNo", shipmentNoJoin);
                    cmd.Parameters.AddWithValue("PageNumber", 1);
                    cmd.Parameters.AddWithValue("RowsOfPage", totalPackage);
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataAdapter da = new(cmd))
                    {

                        da.Fill(dataTable);
                    }
                }
            }
            dataTable.Columns.Add("QRCode", typeof(byte[]));

            for (int i = 0; i < dataTable.Rows.Count; i++)
            {
                var row = dataTable.Rows[i];

                var byteImage = GetQrCode($"{row["Shipment_No"]} {row["Package_No"]} {row["Total_Package"]} {row["Destination_DC_Code"]} {row["Last_Route_Code"]}");
                //var ms = new MemoryStream(byteImage);
                row["QRCode"] = byteImage;
            }

            //            var res = GetQrCode(reportName);
            //foreach (var item in shipments)
            //{
            //    // item.QRCodeColumn = GetQrCode($"{item.Shipment_NoColumn} {item.Package_NoColumn} {item.Total_PackageColumn} {item.Destination_DC_CodeColumn} {item.Last_Route_CodeColumn}");

            //} 


            return dataTable;
        }


        private byte[] GetQrCode(string qrText)
        {
            //QRCodeGenerator qrGenerator = new();

            var writer = new BarcodeWriter<ZXing.Rendering.PixelData>
            {
                Format = BarcodeFormat.QR_CODE,
                Options = new ZXing.Common.EncodingOptions
                {

                    Width = 320,
                    Height = 320,
                    PureBarcode = true,
                    Margin = 2,

                },
                Renderer = new ZXing.Rendering.PixelDataRenderer() { }

            };

            var result = writer.Write(qrText);

            byte[] res = ImageToByte2(result);
            return res;
            // GetQrCode(string qrText)
            //  return File(ImageToByte2(result), "image/jpeg");

        }

        private byte[] ImageToByte2(ZXing.Rendering.PixelData pixelData)
        {
            using (var bitmap = new System.Drawing.Bitmap(pixelData.Width, pixelData.Height, System.Drawing.Imaging.PixelFormat.Format32bppRgb))
            using (var stream = new MemoryStream())
            {
                // lock the data area for fast access
                var bitmapData = bitmap.LockBits(new System.Drawing.Rectangle(0, 0, pixelData.Width, pixelData.Height),
                   System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppRgb);
                try
                {
                    // we assume that the row stride of the bitmap is aligned to 4 byte multiplied by the width of the image
                    System.Runtime.InteropServices.Marshal.Copy(pixelData.Pixels, 0, bitmapData.Scan0,
                       pixelData.Pixels.Length);
                }
                finally
                {
                    bitmap.UnlockBits(bitmapData);
                }
                // save to stream as PNG
                bitmap.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
                return stream.ToArray();
            }
        }


    }


}

public class FileStreemDynamic
{
    public byte[] FileByte { get; set; }
    public string ContentType { get; set; }
    public string FileType { get; set; }
}

