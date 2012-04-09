using System.Web.Mvc;

namespace Uncas.Psen.TestSolution.Web.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return Content("Hello Psen");
        }
    }
}
