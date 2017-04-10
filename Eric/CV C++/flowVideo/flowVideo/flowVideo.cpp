// flowVideo.cpp : Defines the entry point for the console application.
//



#include "stdafx.h"
#include <opencv2\opencv.hpp>
#include <iostream>
#include <string>
#include <sstream>
#pragma warning(disable:4996)

using namespace std;
using namespace cv;

static const int MAX_CORNERS = 1000;

float H = 1; // global variable to moniter height
int W = 1000; // width of gui
int gridM = 20; // size of grid in meters
Point destination;
bool destinationSet = false;
void grid(Mat img);
void CallBackFunc(int event, int x, int y, int flags, void* userdata);
void showDestination(Mat img);
int main()
{
	VideoCapture cap;
	cap.open(1);
	Mat imgA;
	Mat imgB;
	Mat imgC;
	Mat pos = Mat::zeros(W, W, CV_8UC3);
	grid(pos);
	int counter = 1;
	Point2f flow;
	Point2f flowSum;
	Point2f POS1 = Point2f(W / 2, W / 2);
	Point2f POS2;
	Point2f POSM1 = Point2f(2, 2);;
	Point2f POSM2;
	namedWindow("position");
	resizeWindow("position", 600, 600);
	setMouseCallback("position", CallBackFunc, NULL);
	float cornersFound = 0;
	while (1)
	{
		cap >> imgA;
		imgA.copyTo(imgC);
		cvtColor(imgA, imgA, CV_BGR2GRAY);
		Size img_sz = imgA.size();
		int win_size = 10;

		//obtain features to track
		vector<Point2f> cornersA, cornersB;
		const int MAX_CORNERS = 500;
		goodFeaturesToTrack(imgA, cornersA, MAX_CORNERS, 0.01, 5, noArray(), 3, false, 0.04);

		cornersFound = 0;
		
		if (counter != 1)
		{
			cornerSubPix(imgA, cornersA, Size(win_size, win_size), Size(-1, -1), TermCriteria(TermCriteria::MAX_ITER | TermCriteria::EPS, 20, 0.03));
			vector<uchar> features_found;
			calcOpticalFlowPyrLK(imgA, imgB, cornersA, cornersB, features_found, noArray(), Size(win_size * 2 + 1, win_size * 2 + 1), 5, TermCriteria(TermCriteria::MAX_ITER | TermCriteria::EPS, 20, 0.03));

			flowSum = Point2f(1, 1);
			for (int i = 0; i < (int)cornersA.size(); i++)
			{
				if (!features_found[i] == 1)
				{
					continue;
				}
				cornersFound++;
				flowSum = (cornersB[i] - cornersA[i]) + flowSum;
				line(imgC, cornersA[i], cornersB[i], Scalar(0, 255, 0), 2, 8);
			}
			// average distance moved between frames
			flow.x = flowSum.x / cornersFound;
			flow.y = flowSum.y / cornersFound;

			// add amount of distance moved in this frame
			POS2 = POS1 + flow;

			POSM2.x = POSM1.x + ((flow.x*H*.75) / 640);
			POSM2.y = POSM1.y + ((flow.y*H*.55) / 480);
			cout << "X " << POSM2.x << " Y " << POSM2.y << endl;
			//POSM2.y = (POS2.y*H*.55) / W;
			grid(pos);
			if (destinationSet == true)
			{
				showDestination(pos);
			}
			line(pos, POSM1 * (W / gridM), POSM2 * (W / gridM), Scalar(0, 255, 0), 2, 8);
			circle(pos, POSM2 * (W / gridM), 10, Scalar(255, 0, 0), -1);
			putText(pos, to_string(POSM2.x) + " " + to_string(POSM2.y), POSM2 * (W / gridM) + Point2f(15, 15), 1, 1, Scalar(255, 0, 0));
			POS1 = POS2;
			POSM1 = POSM2;
			imshow("Image A", imgA);
			imshow("Image B", imgB);
			imshow("flow", imgC);
			
		}
		
		
		imshow("position", pos);
		imgA.copyTo(imgB);
		waitKey(30);

		counter++;

	}


	return 0;
}
void grid(Mat img)
{
	img = Mat::zeros(W, W, CV_8UC3);
	int pixPM = W / gridM;
	for (int i = 1; i < gridM; i++)
	{
		line(img, Point(1, i*(W / gridM)), Point(W, i*(W / gridM)), Scalar(0, 255, 255), 2, 8);
		line(img, Point(i*(W / gridM), 1), Point(i*(W / gridM), W), Scalar(0, 255, 255), 2, 8);
	}

	
}
void CallBackFunc(int event, int x, int y, int flags, void* userdata)
{
	if (event == EVENT_LBUTTONDOWN)
	{

		destination = Point(x, y);
		destinationSet = true;
		cout << "Left button of the mouse is clicked - position" << destination << endl;
	}
}
void showDestination(Mat img)
{
	int pixPM = W / gridM;
	int col = (destination.x / pixPM);
	int row = (destination.y / pixPM);
	Point pt1 = Point(col*pixPM, row*pixPM);
	Point pt2 = Point((col+1)*pixPM, (row+1)*pixPM);
	rectangle(img, pt1, pt2, Scalar(255, 105, 180), -1, 8);
	
}