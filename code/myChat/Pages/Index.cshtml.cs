using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace myChat.Pages;

public class IndexModel : PageModel
{
    // MB: Replace body with snippet myWeather-onGet
    // MB: Add HttpClient to Program.cs
    private readonly ILogger<IndexModel> _logger;
    private readonly IConfiguration _config;
    private readonly IHttpClientFactory _factory;
    
    public IndexModel(ILogger<IndexModel> logger, IConfiguration config, IHttpClientFactory factory)
    {
        _logger = logger;
        _config = config;
        _factory = factory;
    }
    
    public WeatherForecast[]? Forecasts { get; private set; }
    
    public void OnGet(string url)
    {
        try {
            if (!string.IsNullOrEmpty(url))
                _config["ApiUrl"] = url;
            using (var client = _factory.CreateClient())
            {
                var req = new HttpRequestMessage();
                req.RequestUri = new Uri(_config["ApiUrl"]);
                var response = client.GetStringAsync(url).Result;
                var data = response.ToString();
                Forecasts = JsonSerializer.Deserialize<WeatherForecast[]>(data);
            }
        } catch (Exception ex) {
            var err=ex.Message; //throw;
            _logger.LogError(ex.Message);
        }
    }
}
