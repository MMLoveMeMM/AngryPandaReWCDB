/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <column.hpp>
#include <column_result.hpp>
#include <expr.hpp>

namespace WCDB {

ColumnResult::ColumnResult(const Expr &expr)
    : Describable(expr.getDescription())
{
}

ColumnResult::ColumnResult() : Describable("")
{
}

ColumnResult ColumnResult::Any()
{
    return ColumnResult("*");
}

ColumnResult ColumnResult::Any(const std::string &tableName)
{
    return ColumnResult(tableName + ".*");
}

ColumnResult &ColumnResult::as(const std::string &name)
{
    m_description.append(" AS " + name);
    return *this;
}

} //namespace WCDB
