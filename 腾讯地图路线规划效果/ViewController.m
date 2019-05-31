//
//  ViewController.m
//  腾讯地图路线规划效果
//
//  Created by Pro on 2019/5/31.
//  Copyright © 2019 Pro. All rights reserved.
//

#import "ViewController.h"
#import <QMapKit/QMapKit.h>
#import "CustomAnnotationView.h"


@interface ViewController ()<QMapViewDelegate,QMapViewDelegate>{
    QPointAnnotation * startAnnotation;
    QPointAnnotation * endAnnotation;
}

@property (nonatomic, strong)QMapView *mapView; //地图图层
@property (nonatomic, strong) NSMutableArray<id <QAnnotation> > *annotations;
@property(nonatomic, strong)NSMutableArray * arr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadInfo];
    
    [self loadMapView];
    
    [self loadSearchForStroke];
}


#pragma mark - 地图  -----------
//1.地图初始化
-(void)loadMapView
{
    
    
    self.mapView = [[QMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.mapView.overlookingEnabled = NO;     //    两指上滑3D效果禁用
    self.mapView.showsScale = NO;
    self.mapView.shows3DBuildings = NO;
    
    
    NSString * startLat = @"19.967205";
    NSString * startLon = @"110.410133";
    
    NSString * endLat = @"20.040722";
    NSString * endLon = @"110.231647";
    

    
    self.annotations = [NSMutableArray array];
    
    startAnnotation = [[QPointAnnotation alloc] init];
    startAnnotation.coordinate = CLLocationCoordinate2DMake([startLat doubleValue],[startLon doubleValue]);
    [self.annotations addObject:startAnnotation];
    
    endAnnotation = [[QPointAnnotation alloc] init];
    endAnnotation.coordinate = CLLocationCoordinate2DMake([endLat doubleValue],[endLon doubleValue]);
    [self.annotations addObject:endAnnotation];
    
    [self.mapView addAnnotations:self.annotations];
    if ([startLat isEqual:endLat]&&[endLon isEqual:startLon]) {
        [self.mapView setZoomLevel:15];
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([startLat doubleValue],[startLon doubleValue]);
        return;
    }
    //地图适应
    GLfloat H = 0;
    QMapPoint points[2];
    points[0] = QMapPointForCoordinate(startAnnotation.coordinate);
    points[1] = QMapPointForCoordinate(endAnnotation.coordinate);
    
    QMapRect rect = QBoundingMapRectWithPoints(points, 2);
//  @"88:64
//  @"34:0
    [_mapView setVisibleMapRect:rect edgePadding:UIEdgeInsetsMake(64, 50,H+12+0+50+44, 100) animated:YES];
    
}


- (void)loadSearchForStroke
{
//    腾讯地图使用
//    路线规划服务
    // https://lbs.qq.com/webservice_v1/guide-road.html
//    坐标解压服务
    // https://lbs.qq.com/webservice_v1/guide-road.html#link-seven
//    画折线服务
 //   https://lbs.qq.com/ios_v1/guide-3d.html
    
//    NSString * startLat = @"19.967205";
//    NSString * startLon = @"110.410133";
//
//    NSString * endLat = @"20.040722";
//    NSString * endLon = @"110.231647";

    
//    NSString * from=[NSString stringWithFormat:@"%@,%@",startLat,startLon];
//    NSString * to=[NSString stringWithFormat:@"%@,%@",endLat,endLon];
//    NSDictionary * dict=@{@"from":from,@"to":to,@"key":@"你的key值"};
//    [[HPNetwork shareInstance] Get:@"https://apis.map.qq.com/ws/direction/v1/driving/" server:@"" parameters:dict completionHandle:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
    
    
//        NSDictionary *drivingRoutePlan = [responseObject[@"result"][@"routes"] firstObject];
    
    
        [self.mapView removeOverlays:self.mapView.overlays];
//        NSUInteger count = [drivingRoutePlan[@"polyline"] count];
//        int vCount = (int)count / 2 ;
//        CLLocationCoordinate2D coordinateArray[vCount];
//        NSMutableArray * arra = drivingRoutePlan[@"polyline"];
    
    NSUInteger count = self.arr.count;
    int vCount = (int)count / 2;
    CLLocationCoordinate2D coordinateArry[vCount];
    NSMutableArray * arra = [NSMutableArray arrayWithArray:self.arr];

//    解压缩坐标实现
        for (int i = 2 ; i < arra.count; i ++) {
            double v0 = [arra[i - 2] doubleValue];
            double v1 = [arra[i] doubleValue] / 1000000;
            double vTotal = v0 + v1;
            NSNumber * number = [NSNumber numberWithDouble:vTotal];
            NSMutableArray *newArray = [arra mutableCopy];
            [newArray replaceObjectAtIndex:i withObject:number];
            arra = newArray;
        }
//    构造结构体数组实现
        for (int i = 0; i < count ;i += 2) {
            double vLat = [arra[i] doubleValue];
            double vLon = [arra[i + 1] doubleValue];
            int v = i / 2;
            coordinateArry[v].latitude = vLat;
            coordinateArry[v].longitude = vLon;
        }
//    展示折线到路上
        QPolyline *walkPolyline = [QPolyline polylineWithCoordinates:coordinateArry count:vCount];
        [self.mapView addOverlay:walkPolyline];
    
//    }];
    
    
    
    
}


- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay
{
    QPolylineView *polylineView = [[QPolylineView alloc] initWithPolyline:overlay];
    polylineView.lineWidth = 8;
    polylineView.lineDashPattern = nil;
    polylineView.strokeColor = [UIColor greenColor];
    
    return polylineView;
}


//4.0 annotationView
- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout   = NO;
        
        if (annotation == startAnnotation) {
            annotationView.iconImageStr = @"map_icon_origin";
        }else if(annotation == endAnnotation)
        {
            annotationView.iconImageStr = @"map_icon_destination";
        }else
        {
            annotationView.iconImageStr = @"order_icon_finish";
        }
        return annotationView;
    }
    return nil;
    
    
}

-(void)loadInfo{
    self.arr = [NSMutableArray arrayWithCapacity:0];
//    腾讯webserviceAPI返回的路线点集合
    NSArray * arrsy =        @[
                              @"19.967054",
                              @"110.409423",
                              @"110",
                              @"-47",
                              @"133",
                              @"-113",
                              @"218",
                              @"-334",
                              @"73",
                              @"-61",
                              @"66",
                              @"-34",
                              @"77",
                              @"-89",
                              @"0",
                              @"0",
                              @"1369",
                              @"865",
                              @"0",
                              @"0",
                              @"1150",
                              @"-1930",
                              @"94",
                              @"-104",
                              @"143",
                              @"-62",
                              @"0",
                              @"0",
                              @"108",
                              @"-8",
                              @"-25",
                              @"-706",
                              @"0",
                              @"0",
                              @"40",
                              @"-250",
                              @"60",
                              @"-110",
                              @"80",
                              @"-50",
                              @"4010",
                              @"-230",
                              @"2450",
                              @"-170",
                              @"50",
                              @"20",
                              @"0",
                              @"0",
                              @"30",
                              @"70",
                              @"50",
                              @"60",
                              @"130",
                              @"60",
                              @"130",
                              @"-40",
                              @"60",
                              @"-70",
                              @"40",
                              @"-100",
                              @"0",
                              @"0",
                              @"110",
                              @"-580",
                              @"130",
                              @"-880",
                              @"480",
                              @"-3400",
                              @"190",
                              @"-1540",
                              @"0",
                              @"0",
                              @"210",
                              @"-1550",
                              @"220",
                              @"-1500",
                              @"290",
                              @"-1110",
                              @"90",
                              @"-250",
                              @"100",
                              @"-220",
                              @"170",
                              @"-310",
                              @"1310",
                              @"-2200",
                              @"150",
                              @"-230",
                              @"260",
                              @"-330",
                              @"450",
                              @"-480",
                              @"200",
                              @"-180",
                              @"196",
                              @"-219",
                              @"1244",
                              @"-1271",
                              @"290",
                              @"-320",
                              @"270",
                              @"-240",
                              @"1290",
                              @"-1320",
                              @"1710",
                              @"-1780",
                              @"510",
                              @"-480",
                              @"180",
                              @"-150",
                              @"630",
                              @"-460",
                              @"340",
                              @"-200",
                              @"340",
                              @"-180",
                              @"520",
                              @"-250",
                              @"2690",
                              @"-1180",
                              @"500",
                              @"-170",
                              @"462",
                              @"-58",
                              @"488",
                              @"-32",
                              @"710",
                              @"-70",
                              @"500",
                              @"-60",
                              @"430",
                              @"-90",
                              @"0",
                              @"0",
                              @"130",
                              @"10",
                              @"270",
                              @"-30",
                              @"190",
                              @"-60",
                              @"220",
                              @"-120",
                              @"200",
                              @"-160",
                              @"290",
                              @"-340",
                              @"154",
                              @"-127",
                              @"336",
                              @"-343",
                              @"330",
                              @"-370",
                              @"470",
                              @"-480",
                              @"2050",
                              @"-2170",
                              @"680",
                              @"-600",
                              @"470",
                              @"-310",
                              @"810",
                              @"-430",
                              @"1230",
                              @"-590",
                              @"1110",
                              @"-290",
                              @"670",
                              @"-20",
                              @"1490",
                              @"100",
                              @"0",
                              @"0",
                              @"80",
                              @"-190",
                              @"-70",
                              @"-4290",
                              @"-66",
                              @"-1178",
                              @"-154",
                              @"-4222",
                              @"17",
                              @"-2563",
                              @"-7",
                              @"-1257",
                              @"10",
                              @"-590",
                              @"130",
                              @"-2220",
                              @"168",
                              @"-1309",
                              @"49",
                              @"-294",
                              @"63",
                              @"-137",
                              @"-270",
                              @"-950",
                              @"-179",
                              @"-797",
                              @"-264",
                              @"-1055",
                              @"-194",
                              @"-872",
                              @"-46",
                              @"-259",
                              @"0",
                              @"0",
                              @"-71",
                              @"-503",
                              @"684",
                              @"-194",
                              @"510",
                              @"-170",
                              @"100",
                              @"-40",
                              @"148",
                              @"-130",
                              @"282",
                              @"-50",
                              @"101",
                              @"-40",
                              @"0",
                              @"0",
                              @"-21",
                              @"-153",
                              @"-4",
                              @"-217",
                              @"28",
                              @"-306",
                              @"256",
                              @"-824",
                              @"420",
                              @"-1100",
                              @"340",
                              @"-980",
                              @"160",
                              @"-640",
                              @"70",
                              @"-410",
                              @"40",
                              @"-660",
                              @"-20",
                              @"-600",
                              @"-60",
                              @"-510",
                              @"-90",
                              @"-500",
                              @"-90",
                              @"-640",
                              @"-110",
                              @"-570",
                              @"-222",
                              @"-822",
                              @"0",
                              @"0",
                              @"442",
                              @"-168",
                              @"810",
                              @"-180",
                              @"2790",
                              @"-410",
                              @"120",
                              @"-60",
                              @"710",
                              @"-90",
                              @"1200",
                              @"-210",
                              @"103",
                              @"42",
                              @"79",
                              @"4",
                              @"2728",
                              @"74",
                              @"0",
                              @"0",
                              @"200",
                              @"-100",
                              @"140",
                              @"-3960",
                              @"0",
                              @"0",
                              @"-30",
                              @"-90",
                              @"60",
                              @"-2510",
                              @"-7",
                              @"-1054",
                              @"57",
                              @"-2166",
                              @"80",
                              @"-1210",
                              @"160",
                              @"-1840",
                              @"20",
                              @"-720",
                              @"-20",
                              @"-420",
                              @"-90",
                              @"-740",
                              @"-100",
                              @"-550",
                              @"-530",
                              @"-2570",
                              @"-290",
                              @"-1160",
                              @"-340",
                              @"-1180",
                              @"-120",
                              @"-530",
                              @"-110",
                              @"-820",
                              @"-10",
                              @"-500",
                              @"30",
                              @"-570",
                              @"50",
                              @"-520",
                              @"200",
                              @"-970",
                              @"610",
                              @"-2480",
                              @"60",
                              @"-620",
                              @"-10",
                              @"-700",
                              @"-490",
                              @"-4470",
                              @"-80",
                              @"-600",
                              @"-210",
                              @"-1920",
                              @"-300",
                              @"-2530",
                              @"-240",
                              @"-1160",
                              @"-800",
                              @"-2680",
                              @"-450",
                              @"-1460",
                              @"-180",
                              @"-530",
                              @"-370",
                              @"-1230",
                              @"-280",
                              @"-850",
                              @"-320",
                              @"-1160",
                              @"-100",
                              @"-460",
                              @"-60",
                              @"-510",
                              @"-60",
                              @"-1300",
                              @"-180",
                              @"-5990",
                              @"170",
                              @"-1220",
                              @"350",
                              @"-1790",
                              @"130",
                              @"-870",
                              @"-10",
                              @"-590",
                              @"-20",
                              @"-420",
                              @"-50",
                              @"-600",
                              @"-80",
                              @"-500",
                              @"-80",
                              @"-680",
                              @"-130",
                              @"-1200",
                              @"-90",
                              @"-1060",
                              @"-60",
                              @"-490",
                              @"-250",
                              @"-3800",
                              @"-20",
                              @"-610",
                              @"-100",
                              @"-870",
                              @"0",
                              @"0",
                              @"30",
                              @"-50",
                              @"20",
                              @"-150",
                              @"-70",
                              @"-470",
                              @"-440",
                              @"-2320",
                              @"-160",
                              @"-760",
                              @"-50",
                              @"-190",
                              @"-40",
                              @"-90",
                              @"-140",
                              @"-830",
                              @"-190",
                              @"-1490",
                              @"-80",
                              @"-780",
                              @"0",
                              @"0",
                              @"460",
                              @"10",
                              @"1010",
                              @"-30",
                              @"1270",
                              @"0",
                              @"1100",
                              @"-20",
                              @"7380",
                              @"-30",
                              @"0",
                              @"0",
                              @"220",
                              @"-80",
                              @"40",
                              @"-1610",
                              @"50",
                              @"-650",
                              @"80",
                              @"-490",
                              @"140",
                              @"-540",
                              @"110",
                              @"-350",
                              @"120",
                              @"-310",
                              @"220",
                              @"-470",
                              @"541",
                              @"-1052",
                              @"169",
                              @"-358",
                              @"430",
                              @"-800",
                              @"270",
                              @"-540",
                              @"1290",
                              @"-2460",
                              @"280",
                              @"-590",
                              @"320",
                              @"-740",
                              @"430",
                              @"-1110",
                              @"400",
                              @"-1110",
                              @"1100",
                              @"-3140",
                              @"880",
                              @"-2430",
                              @"60",
                              @"-200",
                              @"350",
                              @"-810",
                              @"210",
                              @"-440",
                              @"250",
                              @"-470",
                              @"680",
                              @"-1130",
                              @"1800",
                              @"-2820",
                              @"190",
                              @"-320",
                              @"780",
                              @"-1230",
                              @"250",
                              @"-370",
                              @"566",
                              @"-941",
                              @"1154",
                              @"-1799",
                              @"2390",
                              @"-3800",
                              @"0",
                              @"0",
                              @"140",
                              @"90",
                              @"460",
                              @"330",
                              @"80",
                              @"-10",
                              @"520",
                              @"-840",
                              @"46",
                              @"-92",
                              @"0",
                              @"0",
                              @"255",
                              @"-38",
                              @"97",
                              @"-43",
                              @"125",
                              @"-133",
                              @"461",
                              @"-759"
                                ];
    self.arr = [NSMutableArray arrayWithArray:arrsy];
    
}
@end
