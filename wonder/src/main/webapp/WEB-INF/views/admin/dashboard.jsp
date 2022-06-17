<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="../inc/top.jsp"%>
<!-- ============================================================== -->
<!-- Top header  -->
<!-- ============================================================== -->

<!-- ============================ Page Title Start================================== -->
<%@ include file="../adminInc/pageTitle.jsp"%>
<!-- ============================ Page Title End ================================== -->

<!-- ============================ User Dashboard ================================== -->
<section class="gray pt-5 pb-5">
	<div class="container-fluid">

		<div class="row">

			<div class="col-lg-3 col-md-4">
				<div class="property_dashboard_navbar">

					<div class="dash_user_avater">
						<img src="https://via.placeholder.com/500x500"
							class="img-fluid avater" alt="">
						<h4>${adminVo.adminId }</h4>
						<span>관리자 계정</span>
					</div>

					<div class="dash_user_menues">

						<ul>
							<li class="active"><a href="<c:url value='/admin/dashboard'/>"><i
									class="fa fa-tachometer-alt"></i>매출현황 통계</a></li>
							<li><a href="<c:url value='/admin/memberList'/>"><i
									class="fa fa-users"></i>회원 관리<span class="notti_coun style-1">4</span></a></li>
							<li><a href="<c:url value='/admin/pdList'/>"><i
									class="fa fa-tasks"></i>게시글 관리<span class="notti_coun style-1">5</span></a></li>
							<li><a href="<c:url value='/admin/nonApprovalList'/>"><i
									class="fa fa-bookmark"></i>거래대기 목록<span
									class="notti_coun style-2">7</span></a></li>
							<li><a href="messages.html"><i class="fa fa-comment"></i>채팅
									목록<span class="notti_coun style-3">3</span></a></li>
							<li><a href="choose-package.html"><i class="fa fa-gift"></i>광고
									목록 목록<span class="expiration">10 days left</span></a></li>
							<li><a href="<c:url value='/admin/editAccount'/>"><i
									class="fa fa-user-tie"></i>내 정보</a></li>
							<li><a
								href="<c:url value='/admin/createAdmin'/>"><i
									class="fa fa-plus-circle"></i>부서별 관리자 생성</a></li>
						</ul>
					</div>
					<div class="dash_user_footer">
						<ul>
							<li><a href="#"><i class="fa fa-power-off"></i></a></li>
							<li><a href="#"><i class="fa fa-envelope"></i></a></li>
							<li><a href="#"><i class="fa fa-cog"></i></a></li>
						</ul>
					</div>
				</div>
			</div>

			<div class="col-lg-9 col-md-8">
				<div class="dashboard-body">

					<div class="row">
						<div class="col-lg-12 col-md-12 col-sm-12">
							<h4>
								매출 현황 통계: <span class="pc-title theme-cl">Sales Status Statistics</span>
							</h4>
						</div>
					</div>

					<div class="row">

						<div class="col-lg-4 col-md-6 col-sm-12">
							<div class="dashboard_stats_wrap widget-1">
								<div class="dashboard_stats_wrap_content">
									<h4>1,222,000 원</h4>
									<span>매출</span>
								</div>
								<div class="dashboard_stats_wrap-icon">
									<i class="ti-money"></i>
								</div>
							</div>
						</div>

						<div class="col-lg-4 col-md-6 col-sm-12">
							<div class="dashboard_stats_wrap widget-3">
								<div class="dashboard_stats_wrap_content">
									<h4>221 건</h4>
									<span>거래건수</span>
								</div>
								<div class="dashboard_stats_wrap-icon">
									<i class="ti-receipt"></i>
								</div>
							</div>
						</div>

						<div class="col-lg-4 col-md-6 col-sm-12">
							<div class="dashboard_stats_wrap widget-2">
								<div class="dashboard_stats_wrap_content">
									<h4>127 명</h4>
									<span>가입자수</span>
								</div>
								<div class="dashboard_stats_wrap-icon">
									<i class="ti-stats-up"></i>
								</div>
							</div>
						</div>

					</div>
					<!--  row -->

					<div class="row">
						<div class="col-lg-8 col-md-7 col-sm-12">
							<div class="card">
								<div class="card-header">
									<h4 class="mb-0">년도별 매출 비교</h4>
								</div>
								<div class="card-body">
									<ul class="list-inline text-center m-t-40">
										<li>
											<h5>
												<i class="fa fa-circle m-r-5 text-warning"></i>2020
											</h5>
										</li>
										<li>
											<h5>
												<i class="fa fa-circle m-r-5 text-danger"></i>2021
											</h5>
										</li>
										<li>
											<h5>
												<i class="fa fa-circle m-r-5 text-success"></i>2022
											</h5>
										</li>
									</ul>
									<div class="chart" id="extra-area-chart" style="height: 300px;"></div>
								</div>
							</div>
						</div>

						<div class="col-lg-4 col-md-5 col-sm-12">
							<div class="card">
								<div class="card-header">
									<h6>알림</h6>
								</div>
								<div class="ground-list ground-list-hove">
									<div class="ground ground-single-list">
										<a href="#">
											<div class="btn-circle-40 theme-cl theme-bg-light">
												<i class="ti-home"></i>
											</div>
										</a>

										<div class="ground-content">
											<h6>
												<a href="#">Your listing <strong>Azreal Modern</strong>
													has been approved!.
												</a>
											</h6>
											<span class="small">Just Now</span>
										</div>
									</div>

									<div class="ground ground-single-list">
										<a href="#">
											<div class="btn-circle-40 theme-cl theme-bg-light">
												<i class="ti-comment-alt"></i>
											</div>
										</a>

										<div class="ground-content">
											<h6>
												<a href="#">Litha Lynes left a review on <strong>Renovated
														Apartment</strong></a>
											</h6>
											<span class="small">20 min ago</span>
										</div>
									</div>

									<div class="ground ground-single-list">
										<a href="#">
											<div class="btn-circle-40 theme-cl theme-bg-light">
												<i class="ti-heart"></i>
											</div>
										</a>

										<div class="ground-content">
											<h6>
												<a href="#">Someone bookmark your View listing!<strong>Sargun
														Villa Bay</strong></a>
											</h6>
											<span class="small">1 day ago</span>
										</div>
									</div>

									<div class="ground ground-single-list">
										<a href="#">
											<div class="btn-circle-40 theme-cl theme-bg-light">
												<i class="ti-home"></i>
											</div>
										</a>

										<div class="ground-content">
											<h6>
												<a href="#">Your listing <strong>Modern Family
														Home</strong> has been approved!.
												</a>
											</h6>
											<span class="small">10 days ago</span>
										</div>
									</div>

									<div class="ground ground-single-list">
										<a href="#">
											<div class="btn-circle-40 theme-cl theme-bg-light">
												<i class="ti-comment-alt"></i>
											</div>
										</a>

										<div class="ground-content">
											<h6>
												<a href="#">Adam Brown left a review on <strong>Renovated
														Apartment</strong></a>
											</h6>
											<span class="small">Just Now</span>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<!-- row -->

					<div class="row">
						<div class="col-lg-12 col-md-12">
							<div class="card">
								<div class="card-header">
									<h4 class="mb-0">Order Status</h4>
								</div>
								<div class="card-body p-0">
									<div class="table-responsive">
										<table class="table table-lg table-hover">
											<thead>
												<tr>
													<th>Name</th>
													<th>Product ID</th>
													<th>Status</th>
													<th>Price</th>
													<th>Date Created</th>
												</tr>
											</thead>

											<tbody>
												<tr>
													<td><a href="#"><img
															src="https://via.placeholder.com/800x500"
															class="avatar avatar-30 mr-2" alt="Avatar">Luxury
															House</a></td>
													<td>#258475</td>
													<td><div class="label text-success bg-success-light">Paid</div></td>
													<td>$ 310</td>
													<td>04/10/2013</td>
												</tr>

												<tr>
													<td><a href="#"><img
															src="https://via.placeholder.com/800x500"
															class="avatar avatar-30 mr-2" alt="Avatar">Sargun
															Apartment</a></td>
													<td>#249578</td>
													<td><div class="label text-warning bg-warning-light">Pending</div></td>
													<td>$ 584.14</td>
													<td>05/08/2014</td>
												</tr>

												<tr>
													<td><a href="#"><img
															src="https://via.placeholder.com/800x500"
															class="avatar avatar-30 mr-2" alt="Avatar">Preet
															Silver City</a></td>
													<td>#248712</td>
													<td><div class="label text-danger bg-danger-light">Cancel</div></td>
													<td>$ 710.5</td>
													<td>11/05/2015</td>
												</tr>

												<tr>
													<td><a href="#"><img
															src="https://via.placeholder.com/800x500"
															class="avatar avatar-30 mr-2" alt="Avatar">Mount
															See Villa</a></td>
													<td>#287246</td>
													<td><div class="label text-success bg-success-light">Paid</div></td>
													<td>$ 482.70</td>
													<td>06/09/2016</td>
												</tr>

											</tbody>
										</table>
									</div>
								</div>
							</div>
						</div>
					</div>
					<!-- row -->

				</div>
			</div>

		</div>
	</div>
</section>
<!-- ============================ User Dashboard End ================================== -->
<%@ include file="../inc/bottom.jsp"%>